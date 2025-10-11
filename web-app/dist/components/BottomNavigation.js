import { jsx as _jsx } from "react/jsx-runtime";
import { Link, useLocation } from 'react-router-dom';
import '../styles/BottomNavigation.css';
const BottomNavigation = () => {
    const location = useLocation();
    const navItems = [
        { path: '/', icon: '🏠', label: 'Home' },
        { path: '/journal', icon: '📖', label: 'Journal' },
        { path: '/activities', icon: '📊', label: 'Stats' },
        { path: '/meditation', icon: '🧘', label: 'Meditation' }
    ];
    return (_jsx("div", { className: "bottom-navigation", children: _jsx("div", { className: "nav-container", children: navItems.map((item, index) => (_jsx(Link, { to: item.path, className: `nav-item ${location.pathname === item.path ? 'active' : ''}`, children: _jsx("span", { className: "nav-icon", children: item.icon }) }, index))) }) }));
};
export default BottomNavigation;
