// Defiant Departmental Suite: Authoritative Utility & Namespace Layer
(function() {
    window.Defiant = {
        State: {
            incidents: {},
            units: {},
            sensors: {},
            officer: {},
            history: [],
            cart: [],
            config: {}
        },
        Utils: {
            // High-Performance HTML Sanitization
            Sanitize: function(str) {
                if (!str || typeof str !== 'string') return str;
                const map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#x27;',
                    "/": '&#x2F;'
                };
                const reg = /[&<>"'/]/ig;
                return str.replace(reg, (match) => (map[match]));
            },

            formatTimestamp: function(ts) {
                const date = new Date(ts * 1000);
                return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            },
            
            worldToMap: function(x, y) {
                const mapConfig = { offsetX: 4000, offsetY: 8000, width: 8500, height: 12500 };
                return { 
                    x: ((x + mapConfig.offsetX) / mapConfig.width) * 100, 
                    y: ((mapConfig.offsetY - y) / mapConfig.height) * 100 
                };
            },
            
            hideAll: function() {
                console.log("[Defiant NUI] hideAll Triggered");
                $('.module-container, .hub-container, .terminal-container, #armory-container, #garage-container, #shotspotter-container, #mdt-terminal, #dispatch-hub, #evidence-container, #forensic-container, #boss-menu-container').each(function() {
                    this.style.setProperty('display', 'none', 'important');
                });
                const resourceName = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'defiantPoliceJob';
                $.post(`https://${resourceName}/close`, JSON.stringify({}));
            }
        }
    };

    // Environment Lockdown: Disable Context Menu & DevTools Shortcuts
    window.addEventListener('contextmenu', (e) => e.preventDefault());
    window.addEventListener('keydown', function(e) {
        if (
            e.key === 'F12' || 
            (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J' || e.key === 'C')) ||
            (e.ctrlKey && e.key === 'U')
        ) {
            e.preventDefault();
        }
    });

    window.addEventListener('keyup', function(e) {
        if (e.key === 'Escape') {
            if (window.Defiant && window.Defiant.Utils) window.Defiant.Utils.hideAll();
        }
    });
    
    console.log("Defiant Namespace Initialized Successfully");
})();
