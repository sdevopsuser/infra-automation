// Real-time chart data from analytics summary API
const ctx = document.getElementById('trendChart').getContext('2d');
const trendChart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: [],
    datasets: [{
      label: 'Feedback Count',
      data: [],
      borderColor: '#3498db',
      backgroundColor: 'rgba(52,152,219,0.1)',
      fill: true,
      tension: 0.3
    }]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { display: false }
    }
  }
});

async function fetchAnalytics() {
  try {
    // Replace with your deployed API endpoint
    const response = await fetch('/analytics/summary');
    if (!response.ok) throw new Error('API error');
    const result = await response.json();
    // Parse the nested JSON in body
    const data = typeof result.body === 'string' ? JSON.parse(result.body) : result.body;
    trendChart.data.labels = data.labels;
    trendChart.data.datasets[0].data = data.trend;
    trendChart.update();
  } catch (err) {
    console.error('Failed to fetch analytics:', err);
  }
}

// Initial fetch and poll every 5 seconds
fetchAnalytics();
setInterval(fetchAnalytics, 5000);
