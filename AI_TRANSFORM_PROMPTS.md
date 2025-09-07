# AI Transform Data - OpenAI Node Configuration

## System Prompt:
```
You are a financial data transformation expert. Your task is to:
1. Transform financial statement data into a standardized long format
2. Ensure consistent account naming and categorization
3. Parse and standardize dates
4. Handle any data quality issues
5. Return structured JSON data

Always explain any decisions you make about data transformation or error handling.
```

## User Prompt:
```
Transform this financial data into a standardized format:

{{ JSON.stringify($json.processedData, null, 2) }}

Errors encountered: {{ JSON.stringify($json.errors, null, 2) }}

Output format should be:
{
  "transformedData": [
    {
      "date": "YYYY-MM-DD",
      "year": YYYY,
      "month": MM,
      "statementType": "Income Statement|Balance Sheet",
      "accountCode": "XXX",
      "accountName": "Name",
      "value": 00000,
      "percent": 0.00
    }
  ],
  "transformationNotes": [],
  "decisions": []
}
```

## Configuration Settings:

### Model:
- **Model**: gpt-4-turbo-preview (or gpt-4, gpt-3.5-turbo for cost savings)

### Parameters:
- **Temperature**: 0.3 (for consistent, deterministic outputs)
- **Max Tokens**: 4096
- **Response Format**: JSON Object

### Additional Options:
- **Top P**: 1
- **Frequency Penalty**: 0
- **Presence Penalty**: 0

## Example Input/Output:

### Input:
```json
{
  "processedData": [
    {
      "statementType": "Income Statement",
      "accountCode": "1A",
      "accountName": "Revenue Tier 1",
      "period": "Period 1",
      "dates": ["2024-01-01T06:00:00.000Z"],
      "value": 725368,
      "percent": 0.2430688477
    }
  ],
  "errors": []
}
```

### Expected Output:
```json
{
  "transformedData": [
    {
      "date": "2024-01-01",
      "year": 2024,
      "month": 1,
      "statementType": "Income Statement",
      "accountCode": "1A",
      "accountName": "Revenue Tier 1",
      "value": 725368,
      "percent": 0.24
    }
  ],
  "transformationNotes": [
    "Standardized date format from ISO to YYYY-MM-DD",
    "Rounded percentages to 2 decimal places"
  ],
  "decisions": [
    "Used first date from dates array as primary date",
    "Maintained original account codes and names"
  ]
}
```

## Key Transformation Rules:

1. **Date Handling**:
   - Convert ISO dates to YYYY-MM-DD format
   - Extract year and month as separate fields
   - Handle multiple date formats gracefully

2. **Account Standardization**:
   - Preserve account codes
   - Standardize account names (remove extra spaces, fix capitalization)
   - Map common variations to standard names

3. **Value Processing**:
   - Ensure numeric values are numbers, not strings
   - Handle nulls and empty values
   - Round percentages appropriately

4. **Error Handling**:
   - Document any issues in transformationNotes
   - Explain decisions made for ambiguous data
   - Continue processing even with partial errors

## Tips for Better Results:

1. **Use GPT-4** for best accuracy (though it costs more)
2. **GPT-3.5-turbo** works well for simpler transformations and is much cheaper
3. **Keep temperature low** (0.2-0.3) for consistent formatting
4. **Enable JSON mode** if available in your n8n version
5. **Test with sample data** before processing large batches

## Cost Optimization:

- **GPT-3.5-turbo**: ~$0.001 per transformation
- **GPT-4**: ~$0.03 per transformation
- **GPT-4-turbo**: ~$0.01 per transformation

For MVP testing, GPT-3.5-turbo is usually sufficient and very cost-effective.
