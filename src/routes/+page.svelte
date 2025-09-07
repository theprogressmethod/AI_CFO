<script>
  import '../app.css';
  import { onMount } from 'svelte';
  import * as XLSX from 'xlsx';

  let files = [];
  let loading = false;
  let results = null;
  let error = null;
  let dragover = false;
  let n8nWebhookUrl = '';

  onMount(() => {
    // Set the n8n webhook URL - replace with your actual n8n webhook URL
    // For local n8n: http://localhost:5678/webhook/process-financials
    // For cloud n8n: https://your-instance.app.n8n.cloud/webhook/process-financials
    n8nWebhookUrl = import.meta.env.VITE_N8N_WEBHOOK_URL || 'http://localhost:5678/webhook/process-financials';
  });

  function handleDrop(e) {
    e.preventDefault();
    dragover = false;
    const droppedFiles = Array.from(e.dataTransfer.files).filter(f => 
      f.name.endsWith('.xlsx') || f.name.endsWith('.xls')
    );
    files = [...files, ...droppedFiles];
  }

  function handleFileSelect(e) {
    const selectedFiles = Array.from(e.target.files).filter(f => 
      f.name.endsWith('.xlsx') || f.name.endsWith('.xls')
    );
    files = [...files, ...selectedFiles];
  }

  function removeFile(index) {
    files = files.filter((_, i) => i !== index);
  }

  async function processFiles() {
    if (files.length === 0) {
      error = 'Please select at least one file';
      return;
    }

    loading = true;
    error = null;
    results = null;

    try {
      const formData = new FormData();
      
      // Add each file to the form data
      for (let i = 0; i < files.length; i++) {
        formData.append(`file_${i}`, files[i]);
      }

      const response = await fetch(n8nWebhookUrl, {
        method: 'POST',
        body: formData
      });

      if (!response.ok) {
        throw new Error(`Server error: ${response.status}`);
      }

      const data = await response.json();
      results = data;

      // If there's binary data, convert it for download
      if (data.binary && data.binary.excel) {
        results.downloadReady = true;
      }

    } catch (err) {
      error = err.message || 'An error occurred while processing the files';
      console.error('Processing error:', err);
    } finally {
      loading = false;
    }
  }

  function downloadExcel() {
    if (!results || !results.binary || !results.binary.excel) return;

    const binaryData = results.binary.excel.data;
    const byteCharacters = atob(binaryData);
    const byteNumbers = new Array(byteCharacters.length);
    
    for (let i = 0; i < byteCharacters.length; i++) {
      byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    
    const byteArray = new Uint8Array(byteNumbers);
    const blob = new Blob([byteArray], { 
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
    });
    
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = results.binary.excel.fileName || 'raw_financials.xlsx';
    a.click();
    window.URL.revokeObjectURL(url);
  }

  function formatValue(value) {
    if (typeof value === 'number') {
      return value.toLocaleString('en-US', { maximumFractionDigits: 2 });
    }
    return value;
  }
</script>

<div class="container">
  <header class="header">
    <h1>Financial Statement Processor</h1>
    <p>Upload Excel files containing Income Statements and Balance Sheets</p>
  </header>

  <div 
    class="upload-area {dragover ? 'dragover' : ''}"
    on:drop={handleDrop}
    on:dragover|preventDefault={() => dragover = true}
    on:dragleave={() => dragover = false}
    on:click={() => document.getElementById('file-input').click()}
  >
    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin: 0 auto 1rem; opacity: 0.5;">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
      <polyline points="17 8 12 3 7 8"></polyline>
      <line x1="12" y1="3" x2="12" y2="15"></line>
    </svg>
    <h2>Drop Excel files here or click to browse</h2>
    <p style="color: var(--text-light); margin-top: 0.5rem;">
      Supports .xlsx and .xls files (max 5 files)
    </p>
    <input 
      id="file-input"
      type="file" 
      accept=".xlsx,.xls" 
      multiple
      on:change={handleFileSelect}
      style="display: none;"
    />
  </div>

  {#if files.length > 0}
    <div class="file-list">
      {#each files as file, i}
        <div class="file-item">
          <div>
            <strong>{file.name}</strong>
            <span style="color: var(--text-light); margin-left: 1rem;">
              {(file.size / 1024).toFixed(1)} KB
            </span>
          </div>
          <button 
            class="btn btn-secondary" 
            on:click={() => removeFile(i)}
            style="padding: 0.5rem 1rem; font-size: 0.875rem;"
          >
            Remove
          </button>
        </div>
      {/each}
    </div>

    <div style="margin-top: 1.5rem; text-align: center;">
      <button 
        class="btn" 
        on:click={processFiles}
        disabled={loading || files.length === 0 || files.length > 5}
      >
        {#if loading}
          <span class="loading"></span>
          Processing...
        {:else}
          Process Financial Statements
        {/if}
      </button>
      
      {#if files.length > 5}
        <p class="warning-message" style="margin-top: 1rem;">
          Please select no more than 5 files for this MVP version
        </p>
      {/if}
    </div>
  {/if}

  {#if error}
    <div class="error-message">
      <strong>Error:</strong> {error}
    </div>
  {/if}

  {#if results}
    <div class="results">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <h2>Processing Results</h2>
        {#if results.downloadReady}
          <button class="btn btn-success" on:click={downloadExcel}>
            Download Excel File
          </button>
        {/if}
      </div>

      {#if results.summary}
        <div class="stats">
          <div class="stat-card">
            <div class="stat-label">Total Records</div>
            <div class="stat-value">{results.summary.totalRecords}</div>
          </div>
          {#if results.summary.dateRange && results.summary.dateRange.from}
            <div class="stat-card">
              <div class="stat-label">Date Range</div>
              <div class="stat-value" style="font-size: 1rem;">
                {results.summary.dateRange.from} to {results.summary.dateRange.to}
              </div>
            </div>
          {/if}
          {#if results.summary.statementTypes}
            <div class="stat-card">
              <div class="stat-label">Statement Types</div>
              <div class="stat-value" style="font-size: 1rem;">
                {results.summary.statementTypes.join(', ')}
              </div>
            </div>
          {/if}
        </div>

        {#if results.summary.notes && results.summary.notes.length > 0}
          <div class="notes-section">
            <h3>Processing Notes</h3>
            <ul>
              {#each results.summary.notes as note}
                <li>{note}</li>
              {/each}
            </ul>
          </div>
        {/if}

        {#if results.summary.decisions && results.summary.decisions.length > 0}
          <div class="notes-section" style="background: #f0f9ff; border-color: #bfdbfe;">
            <h3 style="color: #1e40af;">Decisions Made</h3>
            <ul style="color: #1e3a8a;">
              {#each results.summary.decisions as decision}
                <li>{decision}</li>
              {/each}
            </ul>
          </div>
        {/if}
      {/if}

      {#if results.data && results.data.length > 0}
        <h3 style="margin-top: 2rem; margin-bottom: 1rem;">Data Preview (First 10 Records)</h3>
        <div style="overflow-x: auto;">
          <table class="data-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Statement</th>
                <th>Account Code</th>
                <th>Account Name</th>
                <th>Value</th>
                <th>Percent</th>
              </tr>
            </thead>
            <tbody>
              {#each results.data.slice(0, 10) as row}
                <tr>
                  <td>{row.date}</td>
                  <td>{row.statementType}</td>
                  <td>{row.accountCode}</td>
                  <td>{row.accountName}</td>
                  <td>{formatValue(row.value)}</td>
                  <td>{row.percent ? (row.percent * 100).toFixed(2) + '%' : '-'}</td>
                </tr>
              {/each}
            </tbody>
          </table>
          {#if results.data.length > 10}
            <p style="text-align: center; margin-top: 1rem; color: var(--text-light);">
              Showing 10 of {results.data.length} records. Download the Excel file to see all data.
            </p>
          {/if}
        </div>
      {/if}
    </div>
  {/if}
</div>
