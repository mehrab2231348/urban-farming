<?php
// Monolithic router for Vercel Serverless environment
// Helps compress all PHP pages into a single Serverless Function to prevent build timeouts

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$basename = basename($uri);

// Default routing
if ($basename === '' || $basename === 'api') {
    $basename = 'index.php';
}

// Ensure the routing points to the correct subdirectory if it's a setup file
if (strpos($uri, '/setup/') !== false || $basename === 'test_modal_debug.php' ) {
    $file = __DIR__ . '/setup/' . $basename;
} else if (strpos($uri, '/config/') !== false) {
    $file = __DIR__ . '/config/' . $basename;
} else if (strpos($uri, '/includes/') !== false) {
    $file = __DIR__ . '/includes/' . $basename;
} else {
    $file = __DIR__ . '/' . $basename;
}

if (file_exists($file)) {
    require_once $file;
} else {
    http_response_code(404);
    echo "<h1>404 File Not Found</h1><p>The requested file " . htmlspecialchars($uri) . " was not found on this server.</p>";
}
