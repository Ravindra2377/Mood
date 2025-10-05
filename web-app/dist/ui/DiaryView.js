import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useEffect, useState } from 'react';
import JournalEditor from './JournalEditor';
export default function DiaryView() {
    const [date, setDate] = useState(new Date().toISOString().slice(0, 10));
    const [entries, setEntries] = useState([]);
    const [editing, setEditing] = useState(null);
    useEffect(() => {
        fetchEntries();
    }, [date]);
    async function fetchEntries() {
        try {
            const res = await fetch(`/api/journals?date=${date}`, { credentials: 'include' });
            if (res.ok) {
                const data = await res.json();
                setEntries(data);
            }
        }
        catch (e) {
            console.error(e);
        }
    }
    return (_jsxs("div", { children: [_jsx("h2", { children: "Diary" }), _jsxs("label", { children: ["Date:", _jsx("input", { value: date, onChange: (e) => setDate(e.target.value), type: "date" })] }), _jsx(JournalEditor, { date: date, onSaved: () => { setEditing(null); fetchEntries(); }, initial: editing ?? undefined }), _jsxs("div", { children: [entries.length === 0 && _jsx("p", { children: "No entries for this date" }), entries.map((e) => (_jsx("div", { style: { border: '1px solid #ddd', padding: 8, marginTop: 8 }, children: _jsxs("div", { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center' }, children: [_jsxs("div", { children: [_jsx("h3", { style: { margin: 0 }, children: e.title }), _jsx("div", { children: e.content }), _jsxs("div", { children: ["Progress: ", e.progress ?? '—'] })] }), _jsx("div", { children: _jsx("button", { onClick: () => setEditing(e), children: "Edit" }) })] }) }, e.id)))] })] }));
}
