const io = require("socket.io-client");
const TOKEN = "ut8sjz8mmzcp232zqy51m25n";
function testNamespace(ns) {
    const s = io("http://127.0.0.1:10767" + ns, { extraHeaders: { apptoken: TOKEN, apitoken: TOKEN }});
    s.on("connect", () => console.log(ns, "Connected"));
    s.on("connect_error", (e) => console.log(ns, "Error", e.message));
    const oe = s.onevent;
    s.onevent = function(p) { console.log(ns, "Event", p.data); oe.call(this, p); };
}
testNamespace("/");
testNamespace("/lyrics");
testNamespace("/api");
testNamespace("/plugins");
setTimeout(() => process.exit(0), 4000);
