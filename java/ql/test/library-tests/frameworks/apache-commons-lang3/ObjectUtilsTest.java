import org.apache.commons.lang3.ObjectUtils;

public class ObjectUtilsTest {
  String taint() { return "tainted"; }

  private static class IntSource {
    static int taint() { return 0; }
  }

  void sink(Object o) {}

  void test() throws Exception {
    sink(ObjectUtils.clone(taint())); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.cloneIfPossible(taint())); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.CONST(taint())); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.CONST_SHORT(IntSource.taint())); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.CONST_BYTE(IntSource.taint())); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.defaultIfNull(taint(), null)); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.defaultIfNull(null, taint())); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.firstNonNull(taint(), null, null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.firstNonNull(null, taint(), null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.firstNonNull(null, null, taint())); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.getIfNull(taint(), null)); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.max(taint(), null, null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.max(null, taint(), null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.max(null, null, taint())); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.median(taint(), null, null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.median((String)null, taint(), null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.median((String)null, null, taint())); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.min(taint(), null, null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.min(null, taint(), null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.min(null, null, taint())); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.mode(taint(), null, null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.mode(null, taint(), null)); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.mode(null, null, taint())); // $hasTaintFlow $MISSING:hasValueFlow
    sink(ObjectUtils.requireNonEmpty(taint(), "message")); // $hasTaintFlow $hasValueFlow
    sink(ObjectUtils.requireNonEmpty("not null", taint())); // GOOD (message doesn't propagate to the return)
    sink(ObjectUtils.toString(taint(), "default string")); // GOOD (first argument is stringified)
    sink(ObjectUtils.toString(null, taint())); // $hasTaintFlow $hasValueFlow
  }
}
