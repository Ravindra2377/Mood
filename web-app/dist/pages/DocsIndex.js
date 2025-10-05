import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
export default function DocsIndex() {
    return (_jsxs("div", { style: { padding: 28, fontFamily: 'Inter, system-ui, Roboto, Arial' }, children: [_jsx("h1", { children: "Documentation" }), _jsx("p", { style: { color: '#475569' }, children: "Welcome to the SOUL docs. Select a page below:" }), _jsx("ul", { style: { color: '#475569' }, children: _jsx("li", { children: _jsx("a", { href: "/docs/metrics", onClick: (e) => { e.preventDefault(); history.pushState({}, '', '/docs/metrics'); window.dispatchEvent(new PopStateEvent('popstate')); }, children: "Sleep percent metric" }) }) }), _jsx("p", { style: { marginTop: 18 }, children: _jsx("a", { href: "/", children: "\u2190 Back to app" }) })] }));
}
