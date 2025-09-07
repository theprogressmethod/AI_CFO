<script>
	let files = [];
	let processing = false;
	let results = null;
	let error = null;
	let statusMessage = '';

	// Handle file selection
	function handleFileSelect(event) {
		const selectedFiles = Array.from(event.target.files);
		if (files.length + selectedFiles.length > 5) {
			alert('Maximum 5 files allowed');
			return;
		}
		files = [...files, ...selectedFiles];
	}

	// Handle drag and drop
	function handleDrop(event) {
		event.preventDefault();
		const droppedFiles = Array.from(event.dataTransfer.files);
		if (files.length + droppedFiles.length > 5) {
			alert('Maximum 5 files allowed');
			return;
		}
		files = [...files, ...droppedFiles];
	}

	function handleDragOver(event) {
		event.preventDefault();
	}

	// Remove a file from the list
	function removeFile(index) {
		files = files.filter((_, i) => i !== index);
	}

	// Process files
	async function processFiles() {
		if (files.length === 0) {
			alert('Please select at least one file');
			return;
		}

		processing = true;
		error = null;
		results = null;
		statusMessage = 'Processing files...';

		try {
			const formData = new FormData();
			
			// Append all files to the form data
			files.forEach((file, index) => {
				formData.append(`file_${index}`, file);
			});
			
			statusMessage = `Processing ${files.length} file(s)...`;

			const response = await fetch('http://localhost:5678/webhook/process-financials', {
				method: 'POST',
				body: formData
			});

			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const text = await response.text();
			console.log('Raw response:', text); // Debug log
			
			let data;
			try {
				data = JSON.parse(text);
			} catch (parseError) {
				console.error('JSON parse error:', parseError);
				throw new Error('Invalid response format from server');
			}
			
			// Handle various response formats from n8n
			let processedResults = [];
			
			// If it's already an array, use it
			if (Array.isArray(data)) {
				processedResults = data;
			}
			// If it's an object with a data property
			else if (data && typeof data === 'object') {
				// Check common property names n8n might use
				if (Array.isArray(data.data)) {
					processedResults = data.data;
				} else if (Array.isArray(data.items)) {
					processedResults = data.items;
				} else if (Array.isArray(data.results)) {
					processedResults = data.results;
				} else if (Array.isArray(data.json)) {
					processedResults = data.json;
				} else if (data.json && Array.isArray(data.json.data)) {
					processedResults = data.json.data;
				} else {
					// If it's a single object with the expected properties, wrap it
					if (data['Date Concat'] || data['Year'] || data['Account']) {
						processedResults = [data];
					} else {
						// Try to extract any array from the object
						const arrays = Object.values(data).filter(v => Array.isArray(v));
						if (arrays.length > 0) {
							processedResults = arrays.flat();
						} else {
							console.warn('Unexpected data structure:', data);
							processedResults = [data];
						}
					}
				}
			}

			// Validate and clean the results
			if (processedResults.length > 0) {
				// Check if the first item has the expected structure
				const firstItem = processedResults[0];
				if (typeof firstItem === 'object' && firstItem !== null) {
					results = processedResults;
					statusMessage = `Successfully processed ${files.length} file(s) - ${results.length} rows loaded`;
				} else {
					throw new Error('Invalid data structure in response');
				}
			} else {
				throw new Error('No data returned from server');
			}

		} catch (err) {
			console.error('Processing error:', err);
			error = err.message;
			statusMessage = 'Error processing files';
		} finally {
			processing = false;
		}
	}

	// Test connection to n8n
	async function testConnection() {
		try {
			const response = await fetch('http://localhost:5678/webhook/process-financials', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ test: true })
			});
			
			if (response.ok) {
				const text = await response.text();
				console.log('Test response:', text);
				alert('✅ Successfully connected to n8n!');
			} else {
				alert(`⚠️ n8n responded with status: ${response.status}`);
			}
		} catch (err) {
			alert(`❌ Could not connect to n8n: ${err.message}`);
		}
	}

	// Download results as CSV
	async function downloadCSV() {
		if (!results || results.length === 0) return;

		try {
			// Get headers from the first row
			const headers = Object.keys(results[0]);
			
			// Build CSV content
			let csvContent = headers.join(',') + '\n';
			
			results.forEach(row => {
				const values = headers.map(header => {
					const value = row[header] || '';
					// Escape quotes and wrap in quotes if contains comma, quote, or newline
					if (value.toString().includes(',') || value.toString().includes('"') || value.toString().includes('\n')) {
						return `"${value.toString().replace(/"/g, '""')}"`;
					}
					return value;
				});
				csvContent += values.join(',') + '\n';
			});

			// Create and download
			const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
			const link = document.createElement('a');
			const url = URL.createObjectURL(blob);
			link.href = url;
			link.download = 'standardized_financials.csv';
			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
			URL.revokeObjectURL(url);
		} catch (err) {
			console.error('Download error:', err);
			alert('Error downloading file');
		}
	}

	// Clear all data
	function clearAll() {
		files = [];
		results = null;
		error = null;
		statusMessage = '';
	}
</script>

<main class="container mx-auto p-6 max-w-7xl">
	<div class="mb-8">
		<h1 class="text-2xl font-bold mb-2">Financial Statement Processor</h1>
		<p class="text-gray-600">Transform Excel financial statements into standardized format</p>
	</div>
	
	<!-- File Upload Section -->
	<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
		<div class="flex justify-between items-center mb-4">
			<h2 class="text-lg font-semibold">Upload Files</h2>
			<button 
				on:click={testConnection}
				class="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded hover:bg-gray-200 transition"
			>
				Test Connection
			</button>
		</div>
		
		<!-- Drag and Drop Area -->
		<div 
			on:drop={handleDrop}
			on:dragover={handleDragOver}
			class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-blue-400 transition"
		>
			<p class="text-gray-600 mb-2">Drag and drop Excel files here, or</p>
			<label class="cursor-pointer">
				<input 
					type="file" 
					accept=".xlsx,.xls" 
					multiple 
					on:change={handleFileSelect}
					class="hidden"
				>
				<span class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition inline-block text-sm">
					Browse Files
				</span>
			</label>
			<p class="text-xs text-gray-500 mt-2">Maximum 5 files • Excel format (.xlsx, .xls)</p>
		</div>

		<!-- Selected Files List -->
		{#if files.length > 0}
			<div class="mt-4">
				<div class="text-sm font-medium text-gray-700 mb-2">Selected Files ({files.length}/5)</div>
				<div class="space-y-1">
					{#each files as file, index}
						<div class="flex items-center justify-between bg-gray-50 px-3 py-2 rounded text-sm">
							<span>{file.name}</span>
							<button 
								on:click={() => removeFile(index)}
								class="text-red-600 hover:text-red-800 text-xs"
								disabled={processing}
							>
								Remove
							</button>
						</div>
					{/each}
				</div>
			</div>
		{/if}

		<!-- Action Buttons -->
		<div class="mt-4 flex gap-3">
			<button 
				on:click={processFiles}
				disabled={processing || files.length === 0}
				class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 disabled:bg-gray-300 transition text-sm"
			>
				{processing ? 'Processing...' : 'Process Files'}
			</button>
			<button 
				on:click={clearAll}
				disabled={processing}
				class="bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded hover:bg-gray-50 disabled:bg-gray-100 transition text-sm"
			>
				Clear All
			</button>
		</div>
	</div>

	<!-- Status Message -->
	{#if statusMessage}
		<div class="mb-4 px-4 py-3 rounded text-sm {error ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-blue-50 text-blue-700 border border-blue-200'}">
			{statusMessage}
		</div>
	{/if}

	<!-- Error Display -->
	{#if error}
		<div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-6 text-sm">
			<strong>Error:</strong> {error}
		</div>
	{/if}

	<!-- Results Table -->
	{#if results && results.length > 0}
		<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
			<div class="flex justify-between items-center mb-4">
				<div>
					<h2 class="text-lg font-semibold">Standardized Financial Data</h2>
					<p class="text-sm text-gray-600 mt-1">{results.length} rows total</p>
				</div>
				{#if results.length > 0}
					<button 
						on:click={downloadCSV}
						class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 transition text-sm flex items-center gap-2"
					>
						<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
						</svg>
						Download CSV
					</button>
				{/if}
			</div>
			
			<!-- Scrollable Table Container -->
			<div class="overflow-x-auto border border-gray-200 rounded" style="max-height: 600px; overflow-y: auto;">
				<table class="min-w-full divide-y divide-gray-200">
					<thead class="bg-gray-50 sticky top-0">
						<tr>
							{#if results[0]}
								{#each Object.keys(results[0]) as header}
									<th class="px-4 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider whitespace-nowrap bg-gray-50">
										{header}
									</th>
								{/each}
							{/if}
						</tr>
					</thead>
					<tbody class="bg-white divide-y divide-gray-200">
						{#each results as row, i}
							<tr class="hover:bg-gray-50">
								{#each Object.values(row) as value}
									<td class="px-4 py-3 text-sm text-gray-900 whitespace-nowrap">
										{value !== null && value !== undefined ? value : '-'}
									</td>
								{/each}
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
</main>

<style>
	:global(body) {
		background-color: #f9fafb;
		font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
	}
	
	/* Sticky header for scrollable table */
	thead th {
		position: sticky;
		top: 0;
		z-index: 10;
	}
</style>