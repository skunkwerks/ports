diff --git vendor/github.com/VictoriaMetrics/VictoriaMetrics/lib/encoding/encoding.go vendor/github.com/VictoriaMetrics/VictoriaMetrics/lib/encoding/encoding.go
index f48276f0f..53b95a8a5 100644
--- vendor/github.com/VictoriaMetrics/VictoriaMetrics/lib/encoding/encoding.go
+++ vendor/github.com/VictoriaMetrics/VictoriaMetrics/lib/encoding/encoding.go
@@ -179,9 +179,23 @@ func unmarshalInt64Array(dst []int64, src []byte, mt MarshalType, firstValue int
 	// MarshalVarInt64-encoded delta per item — so each of the itemsCount items
 	// occupies at most binary.MaxVarintLen64 bytes. A larger result means the
 	// input is corrupted or hostile (e.g. a decompression bomb)
-	maxDecompressedSize := itemsCount * binary.MaxVarintLen64
-	// ZSTD window size has minimal limit of 1024
-	maxDecompressedSize = max(maxDecompressedSize, 1024)
+	maxItemsSize := itemsCount * binary.MaxVarintLen64
+
+	// Use the default encoder's maxWindowSize configuration as the maximum
+	// decompressed data size for the decoder.
+	// The decoder may check the window size, which can exceed the size of the
+	// decompressed data. The current limit provides an acceptable level of security.
+	// In the worst case, a corrupted block allocates only 8 MiB of memory.
+	//
+	// github.com/klauspost/compress/zstd has the following params with max at 8MiB
+	// See https://github.com/klauspost/compress/blob/9b8ba6149408b157131b52e424ef97470ced32f7/zstd/encoder_options.go#L42
+	// and https://github.com/klauspost/compress/blob/9b8ba6149408b157131b52e424ef97470ced32f7/zstd/encoder_options.go#L254.
+	//
+	// valyala/gozstd uses max window size based on compress level.
+	// It's 2MiB according to default encoding.getCompressLevel ( 5 by default)
+	// See https://www.jefftk.com/p/zstd-window-size.
+	const maxWindowSize = 8 << 20
+	maxDecompressedSize := max(maxItemsSize, maxWindowSize)
 
 	var err error
 	switch mt {
