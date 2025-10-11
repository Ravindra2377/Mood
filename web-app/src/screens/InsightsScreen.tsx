import React, { useEffect, useRef } from "react";

interface InsightsScreenProps {
  user?: { username?: string };
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
}

const sleepStats = {
  percent: 78,
  goal: "8h Target",
  lastNight: "7.5h Achieved",
  deficit: "0.5h Missing",
};

const moodTrendData = [3, 4, 3, 5, 4, 4, 5];
const moodTrendLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

const InsightsScreen: React.FC<InsightsScreenProps> = ({
  user,
  navigateTo,
  isDarkMode,
}) => {
  const physicalChartRef = useRef<HTMLCanvasElement>(null);
  const moodTrendChartRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    // Physical State Chart
    if (physicalChartRef.current) {
      // @ts-ignore
      if (window.Chart) {
        // Destroy previous chart if exists
        if (physicalChartRef.current._chart) {
          physicalChartRef.current._chart.destroy();
        }
        const ctx = physicalChartRef.current.getContext("2d");
        // @ts-ignore
        physicalChartRef.current._chart = new window.Chart(ctx, {
          type: "doughnut",
          data: {
            datasets: [
              {
                data: [sleepStats.percent, 100 - sleepStats.percent],
                backgroundColor: [
                  "#FBBF24",
                  isDarkMode ? "#4B5563" : "#F3F4F6",
                ],
                borderWidth: 0,
                cutout: "80%",
              },
            ],
          },
          options: {
            responsive: true,
            plugins: {
              legend: { display: false },
              tooltip: { enabled: false },
            },
          },
        });
      }
    }
    // Mood Trend Chart
    if (moodTrendChartRef.current) {
      // @ts-ignore
      if (window.Chart) {
        if (moodTrendChartRef.current._chart) {
          moodTrendChartRef.current._chart.destroy();
        }
        const ctx = moodTrendChartRef.current.getContext("2d");
        const isDark = isDarkMode;
        const gridColor = isDark
          ? "rgba(255, 255, 255, 0.2)"
          : "rgba(0, 0, 0, 0.1)";
        const fontColor = isDark ? "#E5E7EB" : "#374151";
        // @ts-ignore
        moodTrendChartRef.current._chart = new window.Chart(ctx, {
          type: "line",
          data: {
            labels: moodTrendLabels,
            datasets: [
              {
                label: "Mood",
                data: moodTrendData,
                backgroundColor: "rgba(59, 130, 246, 0.2)",
                borderColor: "rgba(59, 130, 246, 1)",
                borderWidth: 2,
                tension: 0.4,
                fill: true,
              },
            ],
          },
          options: {
            scales: {
              y: {
                min: 1,
                max: 5,
                ticks: { stepSize: 1, color: fontColor },
                grid: { color: gridColor },
              },
              x: {
                ticks: { color: fontColor },
                grid: { color: gridColor },
              },
            },
            plugins: { legend: { display: false } },
          },
        });
      }
    }
  }, [isDarkMode]);

  return (
    <div className="screen active calm-gradient insights-container overflow-y-auto">
      <header className="flex justify-between items-center pt-8">
        <h2 className="text-3xl font-bold">Your Insights</h2>
        <div className="avatar">
          <img
            src="https://i.pravatar.cc/100?u=olivia"
            alt="User Avatar"
            className="w-full h-full object-cover"
          />
        </div>
      </header>
      <div className="calendar-week mt-8 mb-2">
        {moodTrendLabels.map((day, idx) => (
          <div
            key={day}
            className={`calendar-day${idx === 1 ? " active" : ""}`}
          >
            <p>{day[0]}</p>
            <p>{21 + idx}</p>
          </div>
        ))}
      </div>
      <div className="stats-card card rounded-2xl p-6">
        <h3 className="stats-title">Physical state</h3>
        <div className="physical-state-content mt-4">
          <div className="chart-container">
            <canvas ref={physicalChartRef} width={128} height={128} />
            <div className="chart-center-text">{sleepStats.percent}%</div>
          </div>
          <div className="stats-details">
            <div className="stat-item">
              <span className="stat-label">Sleep Goal</span>
              <span className="stat-value">{sleepStats.goal}</span>
            </div>
            <div className="stat-item">
              <span className="stat-label">Last Night</span>
              <span className="stat-value">{sleepStats.lastNight}</span>
            </div>
            <div className="stat-item">
              <span className="stat-deficit">Deficit</span>
              <span className="stat-value">{sleepStats.deficit}</span>
            </div>
          </div>
        </div>
      </div>
      <div className="stats-card card rounded-2xl p-6 mt-6">
        <h3 className="stats-title">Mood Trends (Last 7 Days)</h3>
        <canvas ref={moodTrendChartRef} className="mt-4" height={120} />
      </div>
      <div style={{ height: "96px" }} />
    </div>
  );
};

export default InsightsScreen;
