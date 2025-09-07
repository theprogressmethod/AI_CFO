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
			// For now, we'll process each file individually
			// In production, you might want to batch process
			const allResults = [];
			
			for (const file of files) {
				statusMessage = `Processing ${file.name}...`;
				const formData = new FormData();
				formData.append('file', file);

				const response = await fetch('http://localhost:5678/webhook/process-financials', {
					method: 'POST',
					body: formData
				});

				if (!response.ok) {
					throw new Error(`HTTP error! status: ${response.status}`);
				}

				const data = await response.json();
				
				// If the response is an array, add all items
				if (Array.isArray(data)) {
					allResults.push(...data);
				} else if (data.data && Array.isArray(data.data)) {
					allResults.push(...data.data);
				} else {
					// Single object response
					allResults.push(data);
				}
			}

			results = allResults;
			statusMessage = `Successfully processed ${files.length} file(s)`;
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
				alert('✅ Successfully connected to n8n!');
			} else {
				alert(`⚠️ n8n responded with status: ${response.status}`);
			}
		} catch (err) {
			alert(`❌ Could not connect to n8n: ${err.message}`);
		}
	}

	// Download results as Excel
	async function downloadExcel() {
		if (!results || results.length === 0) return;

		try {
			// Convert JSON to CSV for Excel
			const headers = Object.keys(results[0]);
			const csvContent = [
				headers.join(','),
				...results.map(row => 
					headers.map(header => {
						const value = row[header];
						// Handle values with commas or quotes
						if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
							return `"${value.replace(/"/g, '""')}"`;
						}
						return value;
					}).join(',')
				)
			].join('\n');

			// Create blob and download
			const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
			const link = document.createElement('a');
			const url = URL.createObjectURL(blob);
			link.setAttribute('href', url);
			link.setAttribute('download', 'financial_data.csv');
			link.style.visibility = 'hidden';
			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
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

<main class="container mx-auto p-8 max-w-6xl">
	<h1 class="text-4xl font-bold mb-8 text-center">AI CFO Financial Processor</h1>
	
	<!-- Connection Test Button -->
	<div class="mb-6 text-center">
		<button 
			on:click={testConnection}
			class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600 transition"
		>
			Test n8n Connection
		</button>
	</div>

	<!-- File Upload Section -->
	<div class="bg-white rounded-lg shadow-md p-6 mb-8">
		<h2 class="text-2xl font-semibold mb-4">Upload Financial Statements</h2>
		
		<!-- Drag and Drop Area -->
		<div 
			on:drop={handleDrop}
			on:dragover={handleDragOver}
			class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-blue-500 transition cursor-pointer"
		>
			<svg class="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
			</svg>
			<p class="mb-2">Drag and drop Excel files here, or</p>
			<label class="cursor-pointer">
				<input 
					type="file" 
					accept=".xlsx,.xls" 
					multiple 
					on:change={handleFileSelect}
					class="hidden"
				>
				<span class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition inline-block">
					Browse Files
				</span>
			</label>
			<p class="text-sm text-gray-500 mt-2">Maximum 5 files • Excel format (.xlsx, .xls)</p>
		</div>

		<!-- Selected Files List -->
		{#if files.length > 0}
			<div class="mt-6">
				<h3 class="font-semibold mb-2">Selected Files ({files.length}/5)</h3>
				<ul class="space-y-2">
					{#each files as file, index}
						<li class="flex items-center justify-between bg-gray-50 p-3 rounded">
							<span class="text-sm">{file.name}</span>
							<button 
								on:click={() => removeFile(index)}
								class="text-red-500 hover:text-red-700"
								disabled={processing}
							>
								Remove
							</button>
						</li>
					{/each}
				</ul>
			</div>
		{/if}

		<!-- Action Buttons -->
		<div class="mt-6 flex gap-4">
			<button 
				on:click={processFiles}
				disabled={processing || files.length === 0}
				class="bg-green-500 text-white px-6 py-2 rounded hover:bg-green-600 disabled:bg-gray-300 transition"
			>
				{processing ? 'Processing...' : 'Process Files'}
			</button>
			<button 
				on:click={clearAll}
				disabled={processing}
				class="bg-gray-500 text-white px-6 py-2 rounded hover:bg-gray-600 disabled:bg-gray-300 transition"
			>
				Clear All
			</button>
		</div>
	</div>

	<!-- Status Message -->
	{#if statusMessage}
		<div class="mb-4 p-4 rounded-lg {error ? 'bg-red-100 text-red-700' : 'bg-blue-100 text-blue-700'}">
			{statusMessage}
		</div>
	{/if}

	<!-- Error Display -->
	{#if error}
		<div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-8">
			<strong>Error:</strong> {error}
		</div>
	{/if}

	<!-- Results Table -->
	{#if results && results.length > 0}
		<div class="bg-white rounded-lg shadow-md p-6">
			<div class="flex justify-between items-center mb-4">
				<h2 class="text-2xl font-semibold">Processed Financial Data</h2>
				<button 
					on:click={downloadExcel}
					class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition flex items-center gap-2"
				>
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
					</svg>
					Download Excel
				</button>
			</div>
			
			<!-- Scrollable Table Container -->
			<div class="overflow-x-auto">
				<table class="min-w-full table-auto">
					<thead class="bg-gray-50">
						<tr>
							{#if results[0]}
								{#each Object.keys(results[0]) as header}
									<th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
										{header}
									</th>
								{/each}
							{/if}
						</tr>
					</thead>
					<tbody class="bg-white divide-y divide-gray-200">
						{#each results as row, i}
							<tr class="{i % 2 === 0 ? 'bg-white' : 'bg-gray-50'}">
								{#each Object.values(row) as value}
									<td class="px-4 py-2 whitespace-nowrap text-sm text-gray-900">
										{value || '-'}
									</td>
								{/each}
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
			
			<!-- Results Summary -->
			<div class="mt-4 text-sm text-gray-600">
				Showing {results.length} rows
			</div>
		</div>
	{/if}
</main>

<style>
	:global(body) {
		background: linear-gradient(to bottom right, #f3f4f6, #e5e7eb);
		min-height: 100vh;
	}
</style>