import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  WebViewController? _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';
  String _currentUrl = '';
  bool _isViewingTaskFile = false;

  // Base URL for our S3 bucket
  static const String baseUrl = 'https://nurse-task-guides-2024.s3.eu-north-1.amazonaws.com';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _isViewingTaskFile = url.contains('.html') && !url.endsWith('index.html');
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
              _isViewingTaskFile = url.contains('.html') && !url.endsWith('index.html');
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('$baseUrl/index.html'));
  }

  void _performSearch() {
    if (!kIsWeb && _controller != null) {
      // For now, we'll implement a simple search that filters the index page
      // In the future, this could be enhanced with more sophisticated filtering
      if (_searchQuery.isEmpty) {
        _controller!.loadRequest(Uri.parse('$baseUrl/index.html'));
      } else {
        // This is a basic implementation - you could enhance this with
        // JavaScript injection to filter the content on the page
        _controller!.loadRequest(Uri.parse('$baseUrl/index.html'));
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    if (!kIsWeb && _controller != null) {
      _controller!.loadRequest(Uri.parse('$baseUrl/index.html'));
    }
  }

  void _goBackToIndex() {
    if (!kIsWeb && _controller != null) {
      _controller!.loadRequest(Uri.parse('$baseUrl/index.html'));
    }
  }

  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse('$baseUrl/index.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Instructions'),
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[800],
        elevation: 0,
        leading: _isViewingTaskFile && !kIsWeb
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToIndex,
                tooltip: 'Back to Instructions List',
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search task instructions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (value) {
                      _performSearch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _performSearch,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: kIsWeb ? _buildWebFallback() : _buildMobileView(),
      floatingActionButton: FloatingActionButton(
        onPressed: kIsWeb ? _openInBrowser : () {
          _controller?.loadRequest(Uri.parse('$baseUrl/index.html'));
        },
        tooltip: kIsWeb ? 'Open in Browser' : 'Refresh',
        child: Icon(kIsWeb ? Icons.open_in_browser : Icons.refresh),
      ),
    );
  }

  Widget _buildWebFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Task Instructions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'WebView is not available in web mode.\nClick the button below to open in browser.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open Task Instructions'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            baseUrl,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}