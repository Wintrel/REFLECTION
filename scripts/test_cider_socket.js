const io = require("socket.io-client");
const TOKEN = "ut8sjz8mmzcp232zqy51m25n";
const socket = io("http://127.0.0.1:10767", {
    extraHeaders: {
        "apptoken": TOKEN,
        "apitoken": TOKEN
    }
});
const onevent = socket.onevent;
socket.onevent = function (packet) {
    const args = packet.data || [];
    if (args[0] !== "API:Playback") {
        console.log("EVENT:", args[0], JSON.stringify(args[1]));
    }
    onevent.call(this, packet);
};
socket.on("connect", () => {
    console.log("Connected");
});
setTimeout(() => process.exit(0), 10000);
