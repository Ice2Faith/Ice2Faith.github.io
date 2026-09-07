HPROF_FILE=$1
echo hprof: $HPROF_FILE
echo analysis ...
nohup ./ParseHeapDump.sh $HPROF_FILE org.eclipse.mat.api:suspects org.eclipse.mat.api:overview org.eclipse.mat.api:top_components & echo $! > pid.$HPROF_FILE.mat
