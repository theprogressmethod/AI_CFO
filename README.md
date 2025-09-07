# AI CFO - Financial Statement Processor MVP

A simple web application for processing and transforming financial statements (Income Statements and Balance Sheets) into a standardized raw financials format.

## Features

- Upload multiple Excel files (up to 5 for MVP)
- Automatic detection of statement types and periods
- AI-powered data transformation and standardization
- Error handling with explicit decision logging
- Download processed data as Excel file
- Simple, clean web interface

## Tech Stack

- **Frontend**: SvelteKit
- **Processing**: n8n workflow automation
- **AI**: OpenAI GPT-4 (via n8n)
- **Deployment**: Vercel

## Setup Instructions

### 1. Set up n8n Workflow

1. Install n8n locally or use n8n Cloud:
   ```bash
   # Local installation
   npm install -g n8n
   n8n start
   ```

2. Import the workflow:
   - Open n8n (http://localhost:5678)
   - Go to Workflows → Import
   - Import the `n8n-financial-workflow.json` file
   - Configure the OpenAI node with your API key
   - Activate the workflow

3. Note your webhook URL:
   - Local: `http://localhost:5678/webhook/process-financials`
   - Cloud: `https://your-instance.app.n8n.cloud/webhook/process-financials`

### 2. Set up Web Interface

1. Clone the repository:
   ```bash
   cd /Users/thomasmulhern/projects/AI_CFO
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env and add your n8n webhook URL
   ```

4. Run locally:
   ```bash
   npm run dev
   # Open http://localhost:5173
   ```

### 3. Deploy to Vercel

1. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Deploy:
   ```bash
   vercel
   # Follow the prompts
   # Set environment variable VITE_N8N_WEBHOOK_URL in Vercel dashboard
   ```

## Usage

1. Open the web application
2. Upload 1-5 Excel files containing financial statements
3. Click "Process Financial Statements"
4. Review the results and any processing notes
5. Download the standardized raw financials Excel file

## File Format Requirements

Input files should be Excel (.xlsx or .xls) with:
- Clear headers indicating periods
- Account codes in the first column
- Account names in the second column
- Values in subsequent columns
- Percentage columns (optional)

## Data Processing

The system will:
1. Auto-detect statement types (Income Statement, Balance Sheet)
2. Extract period information from headers
3. Unpivot data from wide to long format
4. Standardize account names and codes
5. Handle errors gracefully with explicit logging

## Error Handling

All processing decisions and errors are:
- Logged in the response
- Displayed in the UI
- Included in the output Excel file (Processing Notes tab)

## Development

To modify the n8n workflow:
1. Edit in n8n interface
2. Export as JSON
3. Update documentation

To modify the web interface:
1. Edit files in `/src`
2. Test locally with `npm run dev`
3. Deploy with `vercel --prod`

## Limitations (MVP)

- Maximum 5 files per batch
- Excel format only
- Basic error handling
- No data persistence
- No user authentication

## Future Enhancements

- Support for CSV and other formats
- Advanced mapping and categorization
- Historical data comparison
- API integration
- User accounts and data storage
- Batch processing improvements

## Support

For issues or questions:
1. Check the Processing Notes in the output
2. Review the n8n workflow execution logs
3. Verify file format matches requirements

## License

MIT
