// Example static data for the chart
const ctx = document.getElementById('trendChart').getContext('2d');
const trendChart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    datasets: [{
      label: 'Feedback Count',
      data: [12, 19, 7, 15, 22, 30, 18],
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
