<script>
  import { onMount } from 'svelte';
  import { excelToJson, processFinancialData } from '$lib/excelProcessor.js';
  
  let files = [];
  let processing = false;
  let results = null;
  let error = null;
  let isDragging = false;
  let processedData = [];
  
  function handleDrop(e) {
    e.preventDefault();
    isDragging = false;
    const droppedFiles = Array.from(e.dataTransfer.files).filter(f => 
      f.name.endsWith('.xlsx') || f.name.endsWith('.xls')
    );
    if (droppedFiles.length > 0) {
      files = [...files, ...droppedFiles].slice(0, 10);
    }
  }
  
  function handleFileSelect(e) {
    files = [...files, ...Array.from(e.target.files)].slice(0, 10);
  }
  
  function removeFile(index) {
    files = files.filter((_, i) => i !== index);
  }
  
  async function processFiles() {
    if (files.length === 0) return;
    
    processing = true;
    error = null;
    results = null;
    processedData = [];
    
    try {
      for (const file of files) {
        console.log(`Processing ${file.name}...`);
        
        try {
          const excelData = await excelToJson(file);
          const processed = processFinancialData(excelData, file.name);
          
          if (processed.length > 0) {
            processedData = processedData.concat(processed);
            console.log(`Added ${processed.length} rows from ${file.name}`);
          }
        } catch (fileError) {
          console.error(`Error processing ${file.name}:`, fileError);
        }
      }
      
      if (processedData.length === 0) {
        throw new Error('No data could be extracted from the Excel files');
      }
      
      processedData.sort((a, b) => {
        return a.Year.localeCompare(b.Year) ||
               a.Month.localeCompare(b.Month) ||
               a['Financial Statements'].localeCompare(b['Financial Statements']) ||
               a['Parent Account'].localeCompare(b['Parent Account']) ||
               a.Account.localeCompare(b.Account);
      });
      
      console.log(`Total combined rows: ${processedData.length}`);
      results = processedData;
      
    } catch (err) {
      console.error('Processing error:', err);
      error = err.message;
    } finally {
      processing = false;
    }
  }
  
  function downloadCSV() {
    if (!results) return;
    
    const headers = Object.keys(results[0]);
    const csv = [
      headers.join(','),
      ...results.map(row => 
        headers.map(h => {
          const value = row[h] || '';
          return value.includes(',') ? `"${value}"` : value;
        }).join(',')
      )
    ].join('\n');
    
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Raw_Financials.csv';
    a.click();
  }
  
  function downloadExcel() {
    if (!results) return;
    
    const script = document.createElement('script');
    script.src = 'https://cdn.sheetjs.com/xlsx-0.20.1/package/dist/xlsx.full.min.js';
    script.onload = () => {
      const ws = XLSX.utils.json_to_sheet(results);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Raw Financials');
      XLSX.writeFile(wb, 'Raw_Financials.xlsx');
    };
    document.head.appendChild(script);
  }
  
  function clearAll() {
    files = [];
    results = null;
    error = null;
    processedData = [];
  }
</script>

<div class="min-h-screen bg-gray-50 py-4">
  <div class="max-w-7xl mx-auto px-3">
    <!-- Header -->
    <div class="bg-white rounded shadow-sm p-3 mb-3">
      <h1 class="text-lg font-semibold text-gray-800">Financial Statement Processor</h1>
      <p class="text-xs text-gray-600 mt-0.5">Combine multiple financial statements into standardized format</p>
    </div>
    
    <!-- Main Content -->
    <div class="bg-white rounded shadow-sm p-3">
      <!-- File Upload Area -->
      <div
        class="border-2 border-dashed rounded p-4 text-center transition-colors mb-3
               {isDragging ? 'border-blue-400 bg-blue-50' : 'border-gray-300'}"
        on:drop={handleDrop}
        on:dragover|preventDefault={() => isDragging = true}
        on:dragleave={() => isDragging = false}
      >
        <svg class="mx-auto h-6 w-6 text-gray-400 mb-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
        </svg>
        <p class="text-xs text-gray-600">
          Drop Excel files or
          <label class="text-blue-600 hover:text-blue-500 cursor-pointer ml-1">
            browse
            <input
              type="file"
              multiple
              accept=".xlsx,.xls"
              class="hidden"
              on:change={handleFileSelect}
            />
          </label>
        </p>
        <p class="text-xs text-gray-500 mt-0.5">Income Statements, Balance Sheets (max 10)</p>
      </div>
      
      <!-- Selected Files -->
      {#if files.length > 0}
        <div class="mb-3">
          <div class="flex justify-between items-center mb-1">
            <h3 class="text-xs font-medium text-gray-700">Files ({files.length})</h3>
            <button
              on:click={clearAll}
              class="text-xs text-red-600 hover:text-red-700"
            >
              Clear
            </button>
          </div>
          <div class="space-y-0.5 max-h-24 overflow-y-auto">
            {#each files as file, i}
              <div class="flex items-center justify-between text-xs bg-gray-50 rounded px-2 py-1">
                <span class="text-gray-700 truncate">{file.name}</span>
                <button
                  on:click={() => removeFile(i)}
                  class="text-gray-400 hover:text-red-500 ml-2 text-sm"
                >
                  ×
                </button>
              </div>
            {/each}
          </div>
        </div>
      {/if}
      
      <!-- Process Button -->
      <button
        on:click={processFiles}
        disabled={files.length === 0 || processing}
        class="w-full py-1.5 px-3 border border-transparent rounded text-sm font-medium text-white 
               {files.length === 0 || processing 
                 ? 'bg-gray-400 cursor-not-allowed' 
                 : 'bg-blue-600 hover:bg-blue-700'}"
      >
        {processing ? 'Processing...' : `Process ${files.length || 0} File${files.length !== 1 ? 's' : ''}`}
      </button>
      
      <!-- Error Display -->
      {#if error}
        <div class="mt-3 p-2 bg-red-50 border border-red-200 rounded text-xs text-red-700">
          <strong>Error:</strong> {error}
        </div>
      {/if}
      
      <!-- Results Display -->
      {#if results}
        <div class="mt-3">
          <!-- Results Header -->
          <div class="flex justify-between items-center mb-2 p-2 bg-green-50 border border-green-200 rounded">
            <div>
              <h3 class="text-xs font-medium text-green-900">Raw Financials</h3>
              <p class="text-xs text-green-700">{results.length} rows</p>
            </div>
            <div class="flex gap-1">
              <button
                on:click={downloadCSV}
                class="px-2 py-1 bg-white border border-green-600 text-green-600 text-xs rounded hover:bg-green-50"
              >
                CSV
              </button>
              <button
                on:click={downloadExcel}
                class="px-2 py-1 bg-green-600 text-white text-xs rounded hover:bg-green-700"
              >
                Excel
              </button>
            </div>
          </div>
          
          <!-- Data Table -->
          <div class="border rounded overflow-hidden">
            <div class="overflow-x-auto max-h-80 overflow-y-auto">
              <table class="min-w-full divide-y divide-gray-200 text-xs">
                <thead class="bg-gray-50 sticky top-0">
                  <tr>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Date</th>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Year</th>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Mo</th>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Statement</th>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Parent</th>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Account</th>
                    <th class="px-1 py-1 text-left text-xs font-medium text-gray-700">Attribute</th>
                    <th class="px-1 py-1 text-right text-xs font-medium text-gray-700">Value</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">
                  {#each results as row}
                    <tr class="hover:bg-gray-50">
                      <td class="px-1 py-0.5 text-gray-900">{row['Date Concat']}</td>
                      <td class="px-1 py-0.5 text-gray-600">{row.Year}</td>
                      <td class="px-1 py-0.5 text-gray-600">{row.Month}</td>
                      <td class="px-1 py-0.5 text-gray-700 text-xs">{row['Financial Statements'].replace(' Statement', '')}</td>
                      <td class="px-1 py-0.5 text-gray-700">{row['Parent Account']}</td>
                      <td class="px-1 py-0.5 text-gray-900">{row.Account}</td>
                      <td class="px-1 py-0.5 text-gray-600 text-xs">{row.Attribute}</td>
                      <td class="px-1 py-0.5 text-right font-mono text-gray-900">{row.Value}</td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>