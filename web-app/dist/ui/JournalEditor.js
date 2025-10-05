import { jsxs as _jsxs, jsx as _jsx } from "react/jsx-runtime";
import { useState, useEffect } from 'react';
import { createJournal, updateJournal, deleteJournal } from '../api/journals';
export default function JournalEditor({ date, onSaved, initial }) {
    const [title, setTitle] = useState(initial?.title ?? '');
    const [content, setContent] = useState(initial?.content ?? '');
    const [progress, setProgress] = useState(initial?.progress ?? '');
    const [status, setStatus] = useState('');
    const [editingId, setEditingId] = useState(initial?.id ?? null);
    useEffect(() => {
        if (initial) {
            setTitle(initial.title ?? '');
            setContent(initial.content ?? '');
            setProgress(initial.progress ?? '');
            setEditingId(initial.id ?? null);
        }
        else {
            setTitle('');
            setContent('');
            setProgress('');
            setEditingId(null);
        }
    }, [initial]);
    async function save() {
        try {
            const body = { title, content };
            if (date)
                body.entry_date = date;
            if (progress !== '')
                body.progress = Number(progress);
            let res = null;
            if (editingId) {
                res = await updateJournal(editingId, body);
            }
            else {
                res = await createJournal(body);
            }
            setStatus('Saved');
            setTitle('');
            setContent('');
            setProgress('');
            setEditingId(null);
            try {
                onSaved && onSaved(res);
            }
            catch (e) { }
        }
        catch (e) {
            console.error(e);
            setStatus('Save failed');
        }
    }
    async function doDelete() {
        if (!editingId)
            return;
        try {
            await deleteJournal(editingId);
            setStatus('Deleted');
            setTitle('');
            setContent('');
            setProgress('');
            setEditingId(null);
            try {
                onSaved && onSaved(null);
            }
            catch (e) { }
        }
        catch (e) {
            console.error(e);
            setStatus('Delete failed');
        }
    }
    return (_jsxs("div", { style: { border: '1px solid #eee', padding: 12, marginTop: 12 }, children: [_jsxs("h3", { children: ["Write entry for ", date] }), _jsx("input", { placeholder: "Title", value: title, onChange: (e) => setTitle(e.target.value) }), _jsx("div", { children: _jsx("textarea", { rows: 6, style: { width: '100%' }, value: content, onChange: (e) => setContent(e.target.value) }) }), _jsx("div", { children: _jsxs("label", { children: ["Progress (0-100):", _jsx("input", { type: "number", min: 0, max: 100, value: progress === '' ? '' : progress, onChange: (e) => setProgress(e.target.value === '' ? '' : Number(e.target.value)) })] }) }), _jsx("button", { onClick: save, children: editingId ? 'Update' : 'Save' }), editingId && _jsx("button", { onClick: doDelete, style: { marginLeft: 8 }, children: "Delete" }), _jsx("div", { children: status })] }));
}
