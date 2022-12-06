#!/bin/bash
set -e

## this is for this program only.
## check debug flag
for i in "$@"; do
  if [ "$i" == "--debug" ]; then
    DEBUG="y"
    set -x
  fi
  
done


function print_debug {
  if [ "$DEBUG" == "y" ]; then
    echo "  DEBUG: $1"  
  fi
}

function print_help {
  echo ""
  echo "Usage: install-tap.sh/update-tap.sh -p PROFILE [-f YOUR-YAML]"
  echo "  -p,--profile) mandatory. profile such as full, view, build, run, iterate. "
  echo "  -f,--file) optional. path to yml file. default to ytt *1st.yml + overlay yml"
  echo "  -y,--yes) optioanl. verify the target cluster before proceeding"
  echo "  additional options will NOT be passed to the target program"
  echo "  if multiple options, then last option wins"
  echo "  '=' in --key=value option is optional"
  echo ""
}

function print_help_customizing {
  echo "  Setup tapconfig:"
  echo "    install-tap/01-setup-tapconfig.sh ~/any/path/tap-env"
  echo "    it will do:"
  echo "      cp -r install-tap/tap-env.template /any/path/tap-env"
  echo "      export TAP_ENV=/path/to/tap-env > ~/.tapconfig"
  echo "      export TAP_ENV_DIR=/path/to/ > ~/.tapconfig" 
  echo "      copy tap-values-templates.yml to TAP_ENV_DIR"
  echo ""
}

function run_script {
    SCRIPT_FILE=$1
    chmod +x $SCRIPT_FILE
    echo "======================================================================================="
    echo "[RUN-BEGIN] $@"
    echo ""
    $@
    echo ""
    echo "[RUN-END] $@"
}

function setup_envconfig {
  DEFAULT_ENV_FILE="$SCRIPTDIR/tap-env" 
  ENV_FILE=${1:-$DEFAULT_ENV_FILE}  

  ENV_DIR=$(echo $ENV_FILE | rev | cut -d'/' -f2- | rev)
  echo "$ENV_DIR"
  if [ ! -d "$ENV_DIR" ]; then
    echo "Creating folder $ENV_DIR"
    mkdir -p "$ENV_DIR"
  fi

  ABS_ENV_DIR="$( cd "$( dirname "${ENV_FILE[0]}" )" && pwd )"
  ABS_ENV_FILE="$( cd "$( dirname "${ENV_FILE[0]}" )" && pwd )/$(basename -- $ENV_FILE)"

  if [ ! -f $ABS_ENV_FILE ]; then
    echo "Coping $SCRIPTDIR/tap-env.template to ABS_ENV_FILE: $ABS_ENV_FILE"
    cp $SCRIPTDIR/tap-env.template $ABS_ENV_FILE
  fi
  copy_to_file_if_not_exist $SCRIPTDIR/tap-env.template $ABS_ENV_FILE
  


  echo "Creating ~/.tapconfig for ABS_ENV_FILE: $ABS_ENV_FILE"
  echo "export TAP_ENV=$ABS_ENV_FILE" > ~/.tapconfig
  echo "export TAP_ENV_DIR=$ABS_ENV_DIR" >> ~/.tapconfig
  cat ~/.tapconfig
  echo ""
  echo "Coping tap-values templates to ABS_ENV_DIR: $ABS_ENV_DIR"
  echo " finding setup_tapconfig_copy_files.sh under '$SCRIPTDIR'"
  for file in $(find $SCRIPTDIR -name "setup_tapconfig_copy_files.sh") ; do
    echo "executing $file"
    chmod +x $file
    $file
  done
}

function _decide_tapconfig {
  if [ -f ~/.tapconfig ]; then
    echo "[ENV] Loading env from ~/.tapconfig"
    source ~/.tapconfig
  fi

  TAP_ENV=${TAP_ENV:-$DEFAULT_ENV}
  if [ ! -f $TAP_ENV ]; then
    echo "ERROR: Env file not found '$TAP_ENV'"
    print_help_customizing
    exit 1
  fi
  echo "[ENV] Using env from '$TAP_ENV'"
  source $TAP_ENV
  export TAP_ENV=$TAP_ENV
  export TAP_ENV_DIR=$TAP_ENV_DIR
}

function trim_string {
    echo $(echo $1 | xargs)
}

# ## DEPRECDATED
# function _export_env_file {
#    while IFS= read line || [ -n "$line" ]; do
#       if [ "$line" == "#"* || "$line" == "" ]; then
#          continue
#       fi
#       ## trim leading /trailing whitespace
#       line=$(trim_string "$line")
      
#       key=$(echo $line | cut -d'=' -f1)
#       value=$(echo $line | cut -d'=' -f2- | sed 's/\//\\\//g')
      
#       ## remove 'export ' prefix and trim leading /trailing whitespace 
#       key=$( echo $key | sed 's/^export //g' | xargs)
#       #echo "$key:$value"
#       eval "export $key=$value"
#    done < $TAP_ENV
# }

function load_env_file {
  DEFAULT_ENV_FILE=$1
  # if [ ! -z $TAP_ENV ]; then
  #   echo "[ENV] already loaded '$TAP_ENV'"
  #   return
  # fi
  _decide_tapconfig $DEFAULT_ENV_FILE
  source $TAP_ENV
}

function is_yml_arg_exist {
  for i in "$@"; do
    case $i in
      -f=*|--file=*|-f|--file)
        print_debug "$i"
        return 0
      ;;
    esac
  done
  return 1
}


function exit_if_not_valid_yml {
  YML=$1
  if [ ! -f "$YML" ]; then
    echo "ERROR: File Not found :$YML"
    print_help 
    exit 1
  fi
  set +e
  RESULT=$(grep -r 'profile:' $YML || true;)
  set -e
  if [ "x$RESULT" == "x" ]; then
    echo "ERROR: Malformed YML: $YML"
    print_help
    exit 1
  fi
}

function parse_args {
  ## takes the first arg.
  EXPECTED_KEY=""
  OTHER_OPTIONS=""
  for i in "$@"; do
    print_debug "=== iteration ==="
    print_debug "input: '$i'"
    case $i in
      -f=*|--file=*)
        print_debug "case -f=) $i"
        YML="${i#*=}"
        shift # past argument=value
        ;;
      -f|--file)
        print_debug "case -p)"
        EXPECTED_KEY="YML"
        shift # past argument=value
        ;;
      -p=*|--profile=*)
        print_debug "case-p=) $i"
        PROFILE="${i#*=}"
        shift # past argument=value
        ;;
      -p|--profile)
        print_debug "case -p)"
        EXPECTED_KEY="PROFILE"
        shift # past argument=value
        ;;
      -y|--yes)
        YES="y"
        shift
        ;;
      -h|--help)
        print_help
        print_help_customizing
        exit 0;
        ;;
      *)
        print_debug "case *"
        if [ "$EXPECTED_KEY" == "" ]; then
          OTHER_OPTIONS="$OTHER_OPTIONS $i"
          continue
        fi
        cmd="$EXPECTED_KEY=\$i"
        eval "$cmd"
        EXPECTED_KEY=""
        ;;
    esac
    print_debug "EXPECTED_KEY:$EXPECTED_KEY"
    print_debug "PROFILE:$PROFILE"
    print_debug "YML:$YML"
    print_debug "OTHER_OPTIONS:$OTHER_OPTIONS"
  done

  print_debug "=== FINAL RESULT ==="
  print_debug "PROFILE:$PROFILE"
  print_debug "YML:$YML"
  print_debug "OTHER_OPTIONS:$OTHER_OPTIONS"
  print_debug "===================="

}

function print_current_k8s {
   CONTEXT=$(kubectl config current-context)
   echo "Current cluster: $CONTEXT"
}

function confirm_target_k8s {
    CONTEXT=$(kubectl config current-context)
    read -p "Are you sure the target cluster '$CONTEXT'? (Y/y) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
      echo "Quitting"
      exit 1
    fi
    echo ""
}

function verify_tap_env_param {
  KEY=$1
  VALUE=$2
  if [ "x$VALUE" == "x" ]; then
    echo "$KEY is empty. check TAP_ENV: $TAP_ENV"
    exit 1
  fi
}



function generate_new_filename {
  SRC_FILE_PATH=$1
  PREFIX_TO_ADD=$2
  ## generate NEW_YML filenaming.
  SRC_FILENAME=$(echo $SRC_FILE_PATH | rev | cut -d'/' -f1 | rev)
  NEW_FILENAME="${PREFIX_TO_ADD}-${SRC_FILENAME}"
  echo "$NEW_FILENAME"
}


## fetch IMGPKG_REGISTRY_CA_CERTIFICATE, BUILDSERVICE_REGISTRY_CA_CERTIFICATE 
## in the tap-env file $TAP_ENV
## and save to REGISTRY_CA_FILE_PATH="/tmp/tap_registry_ca.crt" 
function _extract_custom_ca_file_from_env {
  REGISTRY_CA_FILE_PATH=$1
  rm -rf $REGISTRY_CA_FILE_PATH
  if [ -z "$IMGPKG_REGISTRY_CA_CERTIFICATE" ]; then
    echo "[YML] Not Overlaying as IMGPKG_REGISTRY_CA_CERTIFICATE env NOT found"
    return
  fi
  echo "[YML] Extracting Custom CA from $TAP_ENV to $REGISTRY_CA_FILE_PATH"

  if [ -n "$IMGPKG_REGISTRY_CA_CERTIFICATE" ]; then
    echo "$IMGPKG_REGISTRY_CA_CERTIFICATE" | base64 -d > $REGISTRY_CA_FILE_PATH
  fi

  if [ -n "$BUILDSERVICE_REGISTRY_CA_CERTIFICATE" ]; then
    if [ "$IMGPKG_REGISTRY_CA_CERTIFICATE" != "$BUILDSERVICE_REGISTRY_CA_CERTIFICATE" ]; then
      echo "" >> $REGISTRY_CA_FILE_PATH
      echo "$BUILDSERVICE_REGISTRY_CA_CERTIFICATE" | base64 -d >> $REGISTRY_CA_FILE_PATH
    fi
  fi

  if [ ! -f "$REGISTRY_CA_FILE_PATH" ]; then
    echo "ERROR [YML] Extracted Custom CA file is not found. $REGISTRY_CA_FILE_PATH"
    echo "  check IMGPKG_REGISTRY_CA_CERTIFICATE, BUILDSERVICE_REGISTRY_CA_CERTIFICATE in the tap-env file:$TAP_ENV"
    exit 1
  fi
}

## fetch IMGPKG_REGISTRY_CA_CERTIFICATE, BUILDSERVICE_REGISTRY_CA_CERTIFICATE from the tap-env file $TAP_ENV
## overlay to tap values RESULT_YTT_YML
## if no IMGPKG_REGISTRY_CA_CERTIFICATE, copy YML_1st to RESULT_YTT_YML
function overlay_custom_ca_to_yml {
  YML_1st=$1
  REGISTRY_CA_FILE_PATH=$2
  RESULT_YTT_YML=$3

  if [[ ! "$YML_1st" == *"TEMPLATE"* ]]; then
    ## it is not template yml. 
    echo "[WARNING][YML] NO Params Replacement as the filename doesn't include 'TEMPLATE'. $YML_1st"
    cp $YML_1st $RESULT_YTT_YML
    return 
  fi


  if [ -z "$IMGPKG_REGISTRY_CA_CERTIFICATE" ]; then
    echo "[YML] Not Overlaying as IMGPKG_REGISTRY_CA_CERTIFICATE env NOT found"
    cp $YML_1st $RESULT_YTT_YML
    return
  fi
  
  _extract_custom_ca_file_from_env $REGISTRY_CA_FILE_PATH
  
   echo "[YML] Overlaying IMGPKG_REGISTRY_CA_CERTIFICATE from $TAP_ENV to  $RESULT_YTT_YML"
   YML_1st=$YML
   YML_2nd=$COMMON_SCRIPTDIR/tap-values-custom-ca-overlay-template.yaml
   rm -rf $RESULT_YTT_YML
   set -ex
   ytt --ignore-unknown-comments -f $YML_1st -f $YML_2nd -f $REGISTRY_CA_FILE_PATH > $RESULT_YTT_YML
   set +x

}



## replace template with "tap-env" and
## create a new file under NEW_YML_PATH
function replace_key_if_template_yml {
  SRC_YML=$1
  NEW_YML_PATH=$2
  
  if [[ ! "$SRC_YML" == *"TEMPLATE"* ]]; then
    ## it is not template yml. 
    echo "[WARNING][YML] NO Params Replacement as the filename doesn't include 'TEMPLATE'. $SRC_YML"
    cp $SRC_YML $NEW_YML_PATH
    return 
  fi
  echo "[YML] Replacing values from $TAP_ENV to $SRC_YML"
  cp $SRC_YML $NEW_YML_PATH
  ## read all line including the last line without the trailing return char.
  while IFS= read line || [ -n "$line" ]; do
      if [[ "$line" == "#"* || "$line" == "" ]]; then
         continue
      fi
      ## trim leading /trailing whitespace
      line=$(echo "$line" | xargs)
      #echo "$line"
      key=$(echo $line | cut -d'=' -f1)
      value=$(echo $line | cut -d'=' -f2- | sed 's/\//\\\//g')
      #echo "value:$value"
      #echo "sed -i -r 's/$key/$value/g' $NEW_YML"
      sed -i -r "s/$key/$value/g" $NEW_YML_PATH
  done < $TAP_ENV

  #echo "Replaced values to $NEW_YML_PATH"
}

function copy_to_dir_if_not_exist {
  SRC_FILE=$1
  DEST_DIR=$2
  SRC_FILENAME=$(echo $SRC_FILE | rev | cut -d'/' -f1 | rev)
  if [ -f $DEST_DIR/$SRC_FILENAME ]; then
    echo "Skip Coping. File already exist: $DEST_DIR/$SRC_FILENAME "
  else
    echo "Coping $SRC_FILE to $DEST_DIR"
    cp $SRC_FILE $DEST_DIR/
  fi
}

function copy_to_file_if_not_exist {
  SRC_FILE=$1
  DEST_FILE=$2
  if [ -f $DEST_FILE ]; then
    echo "Skip Coping. File already exist: $DEST_FILE "
  else
    echo "Coping $SRC_FILE to $DEST_FILE"
    cp $SRC_FILE $DEST_FILE
  fi
}