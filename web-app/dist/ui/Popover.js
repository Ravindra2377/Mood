import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import React from 'react';
// Simple Popover: expects two children — trigger and panel content.
// @ts-nocheck
export default function Popover(props) {
    const { children, id } = props;
    const [open, setOpen] = React.useState(false);
    const rootRef = React.useRef(null);
    React.useEffect(() => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        function onDoc(e) {
            if (!rootRef.current)
                return;
            if (rootRef.current.contains(e.target))
                return;
            setOpen(false);
        }
        document.addEventListener('click', onDoc);
        return () => document.removeEventListener('click', onDoc);
    }, []);
    const parts = React.Children.toArray(children);
    const trigger = parts[0] || null;
    const panel = parts[1] || null;
    return (_jsxs("div", { className: "popover-root", ref: rootRef, "aria-haspopup": "dialog", children: [_jsx("div", { onClick: () => setOpen((prev) => !prev), "aria-expanded": open, "aria-controls": id, children: trigger }), _jsx("div", { id: id, role: "dialog", className: `popover-panel ${open ? 'show' : ''}`, "aria-hidden": !open, children: _jsx("div", { className: "popover-tip", children: panel }) })] }));
}
