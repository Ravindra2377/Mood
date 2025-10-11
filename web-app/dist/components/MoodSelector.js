import { jsx as _jsx } from "react/jsx-runtime";
export const MoodSelector = ({ selectedMood, onMoodSelect }) => {
    const moods = [
        { value: 1, emoji: '😢', color: '#FF8FA3' },
        { value: 2, emoji: '😕', color: '#8FB4FF' },
        { value: 3, emoji: '😐', color: '#A8A8A8' },
        { value: 4, emoji: '🙂', color: '#FFE66D' },
        { value: 5, emoji: '😊', color: '#A8E6CF' }
    ];
    return (_jsx("div", { className: "mood-selector", children: moods.map((mood) => (_jsx("button", { className: `mood-button ${selectedMood === mood.value ? 'selected' : ''}`, onClick: () => onMoodSelect(mood.value), style: { backgroundColor: selectedMood === mood.value ? mood.color : 'transparent' }, children: _jsx("span", { className: "mood-emoji", children: mood.emoji }) }, mood.value))) }));
};
