/**
 * Provides classes to reason about Unsafe Resource Fetching vulnerabilities in Android.
 */

import java
import semmle.code.java.frameworks.android.WebView
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.ExternalFlow

/**
 * A sink that represents a method that fetches a web resource in Android.
 *
 * Extend this class to add your own Unsafe Resource Fetching sinks.
 */
abstract class UrlResourceSink extends DataFlow::Node {
  /**
   * Returns a description of this vulnerability,
   */
  abstract string getSinkType();
}

/** CSV sink models representing methods susceptible to Unsafe Resource Fetching attacks. */
private class DefaultUrlResourceSinkModel extends SinkModelCsv {
  override predicate row(string row) {
    row =
      [
        "android.webkit;WebView;true;loadUrl;;;Argument[0];unsafe-android-access",
        "android.webkit;WebView;true;postUrl;;;Argument[0];unsafe-android-access"
      ]
  }
}

/**
 * Cross-origin access enabled resource fetch.
 * 
 * It requires JavaScript to be enabled too to be considered a valid sink.
 */
private class CrossOriginUrlResourceSink extends JavaScriptEnabledUrlResourceSink {
  CrossOriginUrlResourceSink() {
    exists(MethodAccess ma, MethodAccess getSettingsMa |
      ma.getMethod() instanceof CrossOriginAccessMethod and
      ma.getArgument(0).(BooleanLiteral).getBooleanValue() = true and
      ma.getQualifier().(VarAccess).getVariable().getAnAssignedValue() = getSettingsMa and
      getSettingsMa.getMethod() instanceof WebViewGetSettingsMethod and
      getSettingsMa.getQualifier().(VarAccess).getVariable().getAnAccess() =
        this.asExpr().(Argument).getCall().getQualifier()
    )
  }

  override string getSinkType() {
    result = "user input vulnerable to cross-origin and sensitive resource disclosure attacks"
  }
}

/**
 * JavaScript enabled resource fetch.
 */
private class JavaScriptEnabledUrlResourceSink extends UrlResourceSink {
  JavaScriptEnabledUrlResourceSink() {
    sinkNode(this, "unsafe-android-access") and
    exists(VarAccess webviewVa, MethodAccess getSettingsMa, Variable v |
      this.asExpr().(Argument).getCall().getQualifier() = webviewVa and
      getSettingsMa.getMethod() instanceof WebViewGetSettingsMethod and
      webviewVa.getVariable().getAnAccess() = getSettingsMa.getQualifier() and
      v.getAnAssignedValue() = getSettingsMa and
      isJSEnabled(v)
    )
  }

  override string getSinkType() { result = "user input vulnerable to XSS attacks" }
}

/**
 * Methods allowing any-local-file and cross-origin access in the WebSettings class
 */
private class CrossOriginAccessMethod extends Method {
  CrossOriginAccessMethod() {
    this.getDeclaringType() instanceof TypeWebSettings and
    this.hasName(["setAllowUniversalAccessFromFileURLs", "setAllowFileAccessFromFileURLs"])
  }
}

/**
 * `setJavaScriptEnabled` method for the webview
 */
private class AllowJavaScriptMethod extends Method {
  AllowJavaScriptMethod() {
    this.getDeclaringType() instanceof TypeWebSettings and
    this.hasName("setJavaScriptEnabled")
  }
}

/**
 * Holds if a call to `v.setJavaScriptEnabled(true)` exists
 */
private predicate isJSEnabled(Variable v) {
  exists(MethodAccess jsa |
    v.getAnAccess() = jsa.getQualifier() and
    jsa.getMethod() instanceof AllowJavaScriptMethod and
    jsa.getArgument(0).(BooleanLiteral).getBooleanValue() = true
  )
}
