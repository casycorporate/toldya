const DEBUG = process.env.FUNCTIONS_DEBUG === "1" || process.env.FUNCTIONS_DEBUG === "true";

function info(message, meta) {
  console.log(message, meta ?? "");
}

function debug(message, meta) {
  if (!DEBUG) return;
  console.log(message, meta ?? "");
}

function warn(message, meta) {
  console.warn(message, meta ?? "");
}

function error(message, meta) {
  console.error(message, meta ?? "");
}

module.exports = { DEBUG, info, debug, warn, error };

