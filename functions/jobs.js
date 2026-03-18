const functions = require("firebase-functions");

const HEADER_NAME = "x-toldya-job-secret";

function getSecret() {
  return process.env.JOBS_SHARED_SECRET || "";
}

function withJobAuth(handler) {
  return async (req, res) => {
    const secret = getSecret();
    if (!secret) {
      console.error("[jobs] JOBS_SHARED_SECRET is not set");
      res.status(500).json({ ok: false, error: "Server not configured" });
      return;
    }

    const provided = String(req.get(HEADER_NAME) || "").trim();
    if (!provided || provided !== secret) {
      res.status(403).json({ ok: false, error: "Forbidden" });
      return;
    }

    return handler(req, res);
  };
}

function onRequestJob(handler, { secrets } = {}) {
  const wrapped = withJobAuth(handler);
  if (secrets && secrets.length > 0) {
    return functions.runWith({ secrets }).https.onRequest(wrapped);
  }
  return functions.https.onRequest(wrapped);
}

module.exports = { HEADER_NAME, withJobAuth, onRequestJob };

