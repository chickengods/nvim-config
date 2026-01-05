#!/bin/bash
# gopls Performance Monitoring Script

echo "=== gopls Performance Monitor ==="
echo "Timestamp: $(date)"
echo

# Find gopls processes
GOPLS_PIDS=$(pgrep -f "gopls")

if [ -z "$GOPLS_PIDS" ]; then
    echo "No gopls processes found"
    exit 0
fi

echo "Active gopls processes:"
for PID in $GOPLS_PIDS; do
    echo "PID: $PID"
    
    # Memory usage
    MEM_KB=$(ps -p $PID -o rss= 2>/dev/null | tr -d ' ')
    if [ ! -z "$MEM_KB" ]; then
        MEM_MB=$((MEM_KB / 1024))
        echo "  Memory: ${MEM_MB}MB"
    fi
    
    # CPU usage
    CPU=$(ps -p $PID -o pcpu= 2>/dev/null | tr -d ' ')
    if [ ! -z "$CPU" ]; then
        echo "  CPU: ${CPU}%"
    fi
    
    # Working directory
    CWD=$(lsof -p $PID 2>/dev/null | grep "cwd" | awk '{print $NF}' | head -1)
    if [ ! -z "$CWD" ]; then
        echo "  Workspace: $CWD"
    fi
    
    echo
done

# Memory usage warning
for PID in $GOPLS_PIDS; do
    MEM_KB=$(ps -p $PID -o rss= 2>/dev/null | tr -d ' ')
    if [ ! -z "$MEM_KB" ] && [ $MEM_KB -gt 4194304 ]; then  # > 4GB
        echo "⚠️  WARNING: gopls PID $PID using >4GB memory. Consider restarting."
    fi
done

echo "=== End Monitor ==="