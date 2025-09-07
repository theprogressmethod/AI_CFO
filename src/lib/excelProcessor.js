import * as XLSX from 'xlsx';

/**
 * Convert Excel file to JSON data, excluding hidden rows/columns
 */
export async function excelToJson(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target.result);
        const workbook = XLSX.read(data, { 
          type: 'array',
          cellDates: true,
          cellNF: false,
          cellText: false,
          cellStyles: true, // Read cell styles to detect hidden rows/columns
          sheetRows: 0 // Read all rows
        });
        
        let allData = [];
        
        workbook.SheetNames.forEach(sheetName => {
          console.log(`Processing sheet: ${sheetName}`);
          const worksheet = workbook.Sheets[sheetName];
          
          // Get sheet metadata for hidden rows/columns
          const rowInfo = worksheet['!rows'] || [];
          const colInfo = worksheet['!cols'] || [];
          
          // Get the range of the sheet
          const range = XLSX.utils.decode_range(worksheet['!ref'] || 'A1');
          
          // Build data array manually, skipping hidden rows/columns
          const sheetData = [];
          
          for (let rowNum = range.s.r; rowNum <= range.e.r; rowNum++) {
            // Skip hidden rows
            if (rowInfo[rowNum] && rowInfo[rowNum].hidden) {
              console.log(`Skipping hidden row ${rowNum + 1}`);
              continue;
            }
            
            const row = [];
            let hasData = false;
            
            for (let colNum = range.s.c; colNum <= range.e.c; colNum++) {
              // Skip hidden columns
              if (colInfo[colNum] && colInfo[colNum].hidden) {
                continue;
              }
              
              const cellAddress = XLSX.utils.encode_cell({ r: rowNum, c: colNum });
              const cell = worksheet[cellAddress];
              
              if (cell) {
                // Get the display value
                let value = '';
                if (cell.w !== undefined) {
                  value = cell.w; // Formatted text
                } else if (cell.v !== undefined) {
                  value = cell.v; // Raw value
                }
                
                row.push(value);
                if (value !== '' && value !== null) {
                  hasData = true;
                }
              } else {
                row.push('');
              }
            }
            
            // Only add rows that have some data
            if (hasData) {
              sheetData.push(row);
            }
          }
          
          console.log(`Sheet ${sheetName}: ${sheetData.length} visible rows with data`);
          
          if (sheetData.length > 0) {
            allData.push({
              sheetName: sheetName,
              data: sheetData
            });
          }
        });
        
        resolve(allData);
      } catch (error) {
        console.error('Error reading Excel:', error);
        reject(error);
      }
    };
    
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
}

/**
 * Process financial template data
 */
export function processFinancialData(sheets, fileName) {
  const results = [];
  
  if (!sheets || sheets.length === 0) {
    console.warn(`No data in ${fileName}`);
    return results;
  }
  
  // Process each sheet
  sheets.forEach(sheet => {
    const sheetResults = processSheet(sheet.sheetName, sheet.data, fileName);
    results.push(...sheetResults);
  });
  
  return results;
}

/**
 * Process a single sheet of financial data
 */
function processSheet(sheetName, data, fileName) {
  const results = [];
  
  if (!data || data.length === 0) {
    return results;
  }
  
  // Determine statement type from sheet name or content
  const statementType = determineStatementType(sheetName, data);
  
  console.log(`Processing ${sheetName} as ${statementType}`);
  
  // Find the structure of the data
  const structure = analyzeStructure(data);
  
  if (structure.type === 'time-series') {
    // Process time-series data (dates in columns)
    results.push(...processTimeSeriesData(data, structure, statementType));
  } else if (structure.type === 'list') {
    // Process list-style data
    results.push(...processListData(data, structure, statementType));
  } else {
    // Try generic processing
    results.push(...processGenericData(data, statementType));
  }
  
  return results;
}

/**
 * Analyze the structure of the data
 */
function analyzeStructure(data) {
  // Look for date patterns in headers
  let dateRowIndex = -1;
  let dateColumnIndex = -1;
  let accountColumnIndex = 0;
  
  // Check first 10 rows for date headers
  for (let i = 0; i < Math.min(10, data.length); i++) {
    const row = data[i];
    if (!row) continue;
    
    let dateCount = 0;
    for (let j = 0; j < row.length; j++) {
      const cell = String(row[j]).toLowerCase();
      if (isDateIndicator(cell)) {
        dateCount++;
      }
    }
    
    // If row has multiple date indicators, it's likely a header row
    if (dateCount >= 2) {
      dateRowIndex = i;
      break;
    }
  }
  
  // Check for account names (usually in first or second column)
  for (let i = 0; i < Math.min(3, data[0]?.length || 0); i++) {
    let accountCount = 0;
    for (let j = 1; j < Math.min(20, data.length); j++) {
      const cell = String(data[j]?.[i] || '').toLowerCase();
      if (isAccountName(cell)) {
        accountCount++;
      }
    }
    if (accountCount >= 3) {
      accountColumnIndex = i;
      break;
    }
  }
  
  if (dateRowIndex >= 0) {
    return {
      type: 'time-series',
      dateRowIndex,
      accountColumnIndex,
      dataStartRow: dateRowIndex + 1
    };
  }
  
  return {
    type: 'generic',
    accountColumnIndex
  };
}

/**
 * Process time-series financial data
 */
function processTimeSeriesData(data, structure, statementType) {
  const results = [];
  const headers = data[structure.dateRowIndex];
  
  // Process each data row
  for (let i = structure.dataStartRow; i < data.length; i++) {
    const row = data[i];
    if (!row || row.length < 2) continue;
    
    // Get account name
    const accountName = String(row[structure.accountColumnIndex] || '').trim();
    
    // Skip empty or invalid rows
    if (!accountName || accountName === '' || 
        accountName.toLowerCase().includes('total') ||
        accountName.toLowerCase().includes('blank')) {
      continue;
    }
    
    // Process each date column
    for (let j = 0; j < headers.length; j++) {
      // Skip the account column
      if (j === structure.accountColumnIndex) continue;
      
      const header = String(headers[j] || '');
      const value = row[j];
      
      // Skip empty values
      if (!value || value === '' || value === 0) continue;
      
      // Parse date from header
      const dateInfo = parseDateInfo(header);
      
      // Determine parent account
      const parentAccount = determineParentAccount(accountName, statementType);
      
      // Format value
      const formattedValue = formatValue(value);
      
      // Add to results
      results.push({
        'Date Concat': dateInfo.dateConcat,
        'Year': dateInfo.year,
        'Month': dateInfo.month,
        'Financial Statements': statementType,
        'Parent Account': parentAccount,
        'Account': accountName,
        'Attribute': dateInfo.attribute,
        'Value': formattedValue
      });
    }
  }
  
  return results;
}

/**
 * Process list-style data
 */
function processListData(data, structure, statementType) {
  const results = [];
  
  // Look for a pattern with Date, Account, Value columns
  let dateCol = -1, accountCol = -1, valueCol = -1;
  
  // Find column indices from headers
  if (data.length > 0) {
    const headers = data[0];
    for (let i = 0; i < headers.length; i++) {
      const header = String(headers[i]).toLowerCase();
      if (header.includes('date') || header.includes('period')) {
        dateCol = i;
      } else if (header.includes('account') || header.includes('description')) {
        accountCol = i;
      } else if (header.includes('amount') || header.includes('value')) {
        valueCol = i;
      }
    }
  }
  
  // If we found the columns, process the data
  if (dateCol >= 0 && accountCol >= 0 && valueCol >= 0) {
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      if (!row) continue;
      
      const dateStr = String(row[dateCol] || '');
      const accountName = String(row[accountCol] || '').trim();
      const value = row[valueCol];
      
      if (!accountName || !value) continue;
      
      const dateInfo = parseDateInfo(dateStr);
      const parentAccount = determineParentAccount(accountName, statementType);
      const formattedValue = formatValue(value);
      
      results.push({
        'Date Concat': dateInfo.dateConcat,
        'Year': dateInfo.year,
        'Month': dateInfo.month,
        'Financial Statements': statementType,
        'Parent Account': parentAccount,
        'Account': accountName,
        'Attribute': dateInfo.attribute,
        'Value': formattedValue
      });
    }
  }
  
  return results;
}

/**
 * Generic data processing fallback
 */
function processGenericData(data, statementType) {
  const results = [];
  
  // Try to find any numerical data and process it
  for (let i = 0; i < data.length; i++) {
    const row = data[i];
    if (!row || row.length < 2) continue;
    
    // Assume first column is account name
    const accountName = String(row[0] || '').trim();
    if (!accountName || accountName === '') continue;
    
    // Process any numerical values in the row
    for (let j = 1; j < row.length; j++) {
      const value = row[j];
      if (typeof value === 'number' || (typeof value === 'string' && /^\d/.test(value))) {
        const parentAccount = determineParentAccount(accountName, statementType);
        const formattedValue = formatValue(value);
        
        // Use generic date for now
        results.push({
          'Date Concat': 'Dec 2024',
          'Year': '2024',
          'Month': '12',
          'Financial Statements': statementType,
          'Parent Account': parentAccount,
          'Account': accountName,
          'Attribute': '12/31/2024',
          'Value': formattedValue
        });
      }
    }
  }
  
  return results;
}

/**
 * Check if a string indicates a date
 */
function isDateIndicator(str) {
  const s = String(str).toLowerCase();
  return s.includes('2023') || s.includes('2024') || s.includes('2025') ||
         s.includes('jan') || s.includes('feb') || s.includes('mar') ||
         s.includes('apr') || s.includes('may') || s.includes('jun') ||
         s.includes('jul') || s.includes('aug') || s.includes('sep') ||
         s.includes('oct') || s.includes('nov') || s.includes('dec') ||
         s.includes('q1') || s.includes('q2') || s.includes('q3') || s.includes('q4') ||
         s.includes('ending') || s.includes('period') ||
         /^\d{1,2}\/\d{1,2}\/\d{2,4}$/.test(s) || // MM/DD/YYYY
         /^\d{5}$/.test(s); // Excel serial date
}

/**
 * Check if a string is likely an account name
 */
function isAccountName(str) {
  const s = String(str).toLowerCase();
  return (s.includes('revenue') || s.includes('expense') || s.includes('asset') ||
          s.includes('liability') || s.includes('equity') || s.includes('cash') ||
          s.includes('receivable') || s.includes('payable') || s.includes('inventory') ||
          s.includes('cogs') || s.includes('income') || s.includes('profit')) &&
         s.length > 3 && s.length < 100;
}

/**
 * Parse date information from a string
 */
function parseDateInfo(dateStr) {
  const str = String(dateStr).toLowerCase();
  let year = '2024';
  let month = '12';
  let dateConcat = 'Dec 2024';
  let attribute = '12/31/2024';
  
  // Check for year
  const yearMatch = str.match(/20\d{2}/);
  if (yearMatch) {
    year = yearMatch[0];
  }
  
  // Check for month
  const months = {
    'jan': { num: '1', name: 'Jan', lastDay: '31' },
    'feb': { num: '2', name: 'Feb', lastDay: '28' },
    'mar': { num: '3', name: 'Mar', lastDay: '31' },
    'apr': { num: '4', name: 'Apr', lastDay: '30' },
    'may': { num: '5', name: 'May', lastDay: '31' },
    'jun': { num: '6', name: 'Jun', lastDay: '30' },
    'jul': { num: '7', name: 'Jul', lastDay: '31' },
    'aug': { num: '8', name: 'Aug', lastDay: '31' },
    'sep': { num: '9', name: 'Sep', lastDay: '30' },
    'oct': { num: '10', name: 'Oct', lastDay: '31' },
    'nov': { num: '11', name: 'Nov', lastDay: '30' },
    'dec': { num: '12', name: 'Dec', lastDay: '31' }
  };
  
  for (const [key, info] of Object.entries(months)) {
    if (str.includes(key)) {
      month = info.num;
      dateConcat = `${info.name} ${year}`;
      attribute = `${month}/${info.lastDay}/${year}`;
      break;
    }
  }
  
  // Check for quarters
  if (str.includes('q1')) {
    month = '3';
    dateConcat = `Q1 ${year}`;
    attribute = `3/31/${year}`;
  } else if (str.includes('q2')) {
    month = '6';
    dateConcat = `Q2 ${year}`;
    attribute = `6/30/${year}`;
  } else if (str.includes('q3')) {
    month = '9';
    dateConcat = `Q3 ${year}`;
    attribute = `9/30/${year}`;
  } else if (str.includes('q4')) {
    month = '12';
    dateConcat = `Q4 ${year}`;
    attribute = `12/31/${year}`;
  }
  
  // Handle Excel serial dates
  if (/^\d{5}$/.test(dateStr)) {
    const serial = parseInt(dateStr);
    const excelDate = new Date((serial - 25569) * 86400 * 1000);
    year = String(excelDate.getFullYear());
    month = String(excelDate.getMonth() + 1);
    const monthName = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][excelDate.getMonth()];
    dateConcat = `${monthName} ${year}`;
    attribute = `${month}/${excelDate.getDate()}/${year}`;
  }
  
  return { year, month, dateConcat, attribute };
}

/**
 * Determine statement type from sheet name or content
 */
function determineStatementType(sheetName, data) {
  const name = sheetName.toLowerCase();
  
  // Check sheet name
  if (name.includes('income') || name.includes('p&l') || name.includes('profit')) {
    return 'Income Statement';
  } else if (name.includes('balance') || name.includes('bs')) {
    return 'Balance Sheet';
  } else if (name.includes('cash')) {
    return 'Cash Flow Statement';
  }
  
  // Check content for clues
  const contentStr = data.slice(0, 10).flat().join(' ').toLowerCase();
  if (contentStr.includes('revenue') || contentStr.includes('expense')) {
    return 'Income Statement';
  } else if (contentStr.includes('asset') || contentStr.includes('liabilit')) {
    return 'Balance Sheet';
  } else if (contentStr.includes('operating activities') || contentStr.includes('investing')) {
    return 'Cash Flow Statement';
  }
  
  return 'Financial Statement';
}

/**
 * Determine parent account based on account name and statement type
 */
function determineParentAccount(accountName, statementType) {
  const accountLower = accountName.toLowerCase();
  
  if (statementType === 'Income Statement') {
    if (accountLower.includes('revenue') || accountLower.includes('sales')) {
      return 'Revenue';
    } else if (accountLower.includes('cogs') || accountLower.includes('cost of goods')) {
      return 'COGS';
    } else if (accountLower.includes('gross profit')) {
      return 'Gross Profit';
    } else if (accountLower.includes('operating') && accountLower.includes('expense')) {
      return 'Operating Expenses';
    } else if (accountLower.includes('ebitda')) {
      return 'EBITDA';
    } else if (accountLower.includes('depreciation') || accountLower.includes('amortization')) {
      return 'D&A';
    } else if (accountLower.includes('interest')) {
      return 'Interest';
    } else if (accountLower.includes('tax')) {
      return 'Taxes';
    } else if (accountLower.includes('net income') || accountLower.includes('net profit')) {
      return 'Net Income';
    }
    return 'Other Income/Expense';
  } 
  
  else if (statementType === 'Balance Sheet') {
    if (accountLower.includes('cash') && !accountLower.includes('flow')) {
      return 'Assets';
    } else if (accountLower.includes('receivable')) {
      return 'Assets';
    } else if (accountLower.includes('inventory')) {
      return 'Assets';
    } else if (accountLower.includes('prepaid')) {
      return 'Assets';
    } else if (accountLower.includes('property') || accountLower.includes('equipment')) {
      return 'Assets';
    } else if (accountLower.includes('asset')) {
      return 'Assets';
    } else if (accountLower.includes('payable')) {
      return 'Liabilities';
    } else if (accountLower.includes('debt') || accountLower.includes('loan')) {
      return 'Liabilities';
    } else if (accountLower.includes('liabilit')) {
      return 'Liabilities';
    } else if (accountLower.includes('equity') || accountLower.includes('capital')) {
      return 'Equity';
    } else if (accountLower.includes('retained')) {
      return 'Equity';
    }
    return 'Other';
  }
  
  return 'Other';
}

/**
 * Format value as currency
 */
function formatValue(value) {
  if (value === null || value === undefined || value === '') {
    return '$0';
  }
  
  const valueStr = String(value);
  if (valueStr.startsWith('$')) {
    return valueStr;
  }
  
  // Handle percentages
  if (valueStr.includes('%')) {
    return valueStr;
  }
  
  // Try to parse as number
  const cleaned = valueStr.replace(/[^0-9.-]/g, '');
  const num = parseFloat(cleaned);
  
  if (isNaN(num)) {
    return valueStr;
  }
  
  // Format with $ and commas
  const formatted = Math.abs(num).toLocaleString('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  });
  
  return num < 0 ? `-$${formatted}` : `$${formatted}`;
}