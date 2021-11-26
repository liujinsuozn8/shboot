source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

# resources/log.properties 需要开放全部的 logger 配置
# rootLogger = INFO,stdout,RAF,RF
import log/logger/auto

Log::DEBUG 'aaa'
Log::INFO 'bbb'
Log::WARN 'ccc'
Log::ERROR 'ddd'
Log::FATAL 'eee'