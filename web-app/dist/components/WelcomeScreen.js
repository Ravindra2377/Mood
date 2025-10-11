import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { BrainCharacter } from './Characters';
import '../styles/WelcomeScreen.css';
const WelcomeScreen = ({ onComplete }) => {
    const handleStartJourney = () => {
        onComplete('Olivia');
    };
    return (_jsx("div", { className: "welcome-container", children: _jsxs("div", { className: "welcome-content", children: [_jsxs("div", { className: "brand-header", children: [_jsx("h1", { className: "brand-name", children: "mindcare" }), _jsx("div", { className: "brand-dot" })] }), _jsx("div", { className: "character-container floating-element", children: _jsx(BrainCharacter, {}) }), _jsxs("div", { className: "welcome-text", children: [_jsx("h2", { children: "Your mental health matters" }), _jsx("p", { children: "Start your journey with us" })] }), _jsx("button", { className: "cta-button", onClick: handleStartJourney, children: "Let's start now" })] }) }));
};
export default WelcomeScreen;
