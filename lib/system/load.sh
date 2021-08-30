___boot___=$( cd ${BASH_SOURCE[0]%/*}/../.. && pwd )

source "${___boot___}/lib/system/env/env.sh"
source "${___boot___}/lib/system/builtin/path.sh"
source "${___boot___}/lib/system/builtin/array.sh"
source "${___boot___}/lib/system/exception/exception.sh"

# Load import function to environment
source "${___boot___}/lib/system/import/import.sh"