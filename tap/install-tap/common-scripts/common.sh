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

function print_help {
  echo ""
  echo "Usage: $0 -p PROFILE [-f YOUR-YAML]"
  echo "Usage: $0 -p=PROFILE [-f=YOUR-YAML]"
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


function set_tapconfig {
  DEFAULT_ENV_PATH="$SCRIPTDIR/tap-env" 
  ENV_PATH=${1:-$DEFAULT_ENV_PATH}  

  ENV_PATH_DIR=$(echo $ENV_PATH | rev | cut -d'/' -f2- | rev)
  echo "$ENV_PATH_DIR"
  if [ ! -d "$ENV_PATH_DIR" ]; then
    echo "Creating folder $ENV_PATH_DIR"
    mkdir -p "$ENV_PATH_DIR"
  fi

  ABS_ENV_DIR="$( cd "$( dirname "${ENV_PATH[0]}" )" && pwd )"
  ABS_ENV_PATH="$( cd "$( dirname "${ENV_PATH[0]}" )" && pwd )/$(basename -- $ENV_PATH)"

  if [ ! -f $ABS_ENV_PATH ]; then
    echo "Coping $SCRIPTDIR/tap-env.template to $ABS_ENV_PATH"
    cp $SCRIPTDIR/tap-env.template $ABS_ENV_PATH
  fi
  echo "Creating ~/.tapconfig for TAP_ENV $ABS_ENV_PATH"
  echo "export TAP_ENV=$ABS_ENV_PATH" > ~/.tapconfig
  echo "export TAP_ENV_DIR=$ABS_ENV_DIR" >> ~/.tapconfig
  echo ""
  cat ~/.tapconfig
  echo ""
  echo "Coping tap-values templates to $ABS_ENV_DIR"
  for file in $(find $SCRIPTDIR -name "setup_tapconfig._copy_files.sh") ; do
    echo "executing $file"
    sh $file
  done
}

function load_env_file {
  DEFAULT_ENV=$1

  if [ -f ~/.tapconfig ]; then
    echo "Loading TAP_ENV from ~/.tapconfig"
    source ~/.tapconfig
  fi

  TAP_ENV=${TAP_ENV:-$DEFAULT_ENV}
  if [ ! -f $TAP_ENV ]; then
    echo "ERROR: Env file not found $TAP_ENV"
    print_help_customizing
    exit 1
  fi
  echo "Using env from '$TAP_ENV'"
  export TAP_ENV=$TAP_ENV
  source $TAP_ENV
}

function print_debug {
  if [ "$DEBUG" == "y" ]; then
    echo "  DEBUG: $1"  
  fi
}

function is_yml_arg_not_exist {
  for i in "$@"; do
    case $i in
      -f=*|--file=*|-f|--file)
        print_debug "$i"
        return 1
      ;;
    esac
  done
  return 0
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


function confirm_target_k8s {
    CONTEXT=$(kubectl config current-context)
    read -p "Are you sure the target cluster '$CONTEXT'? (Y/y) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
      echo "Quitting"
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
    echo "No IMGPKG_REGISTRY_CA_CERTIFICATE env"
    return
  fi
  echo "Extracting CA from $TAP_ENV to $REGISTRY_CA_FILE_PATH"

  if [ -n "$IMGPKG_REGISTRY_CA_CERTIFICATE" ]; then
    echo $IMGPKG_REGISTRY_CA_CERTIFICATE | base64 -d > $REGISTRY_CA_FILE_PATH
  fi
  if [ -n "$BUILDSERVICE_REGISTRY_CA_CERTIFICATE" ]; then
    if [ "$IMGPKG_REGISTRY_CA_CERTIFICATE" != "$BUILDSERVICE_REGISTRY_CA_CERTIFICATE" ]; then
      echo $BUILDSERVICE_REGISTRY_CA_CERTIFICATE | base64 -d >> $REGISTRY_CA_FILE_PATH
    fi
  fi
  if [ ! -f "$REGISTRY_CA_FILE_PATH" ]; then
    echo "ERROR: CA file is not generated. $REGISTRY_CA_FILE_PATH"
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

  if [ -z "$IMGPKG_REGISTRY_CA_CERTIFICATE" ]; then
    echo "No IMGPKG_REGISTRY_CA_CERTIFICATE env"
    cp $YML_1st $RESULT_YTT_YML
    return
  fi
  
  _extract_custom_ca_file_from_env $REGISTRY_CA_FILE_PATH
  
   echo "Overlaying IMGPKG_REGISTRY_CA_CERTIFICATE from $TAP_ENV to  $RESULT_YTT_YML"
   YML_1st=$YML
   YML_2nd=$COMMON_SCRIPTDIR/tap-values-custom-ca-overlay-template.yaml
   rm -rf $RESULT_YTT_YML
   set -ex
   ytt --ignore-unknown-comments -f $YML_1st -f $YML_2nd -f $REGISTRY_CA_FILE_PATH > $RESULT_YTT_YML
   set +x
   echo "Overlaying IMGPKG_REGISTRY_CA_CERTIFICATE from $TAP_ENV to  $RESULT_YTT_YML"

}



## replace template with "tap-env" and
## create a new file under /tmp
function replace_key_if_template_yml {
  YML=$1
  NEW_YML_PATH=$2
  
  if [[ ! "$YML" == *"TEMPLATE"* ]]; then
    ## it is not template yml. 
    echo "NO Params Replacement as the filename doesn'tinclude 'TEMPLATE'. $YML"
    cp $YML $NEW_YML_PATH
    return 
  fi
  echo "Replacing values from $TAP_ENV to  $YML"

  cp $YML $NEW_YML_PATH
  ## read all line including the last line without the trailing return char.
  while IFS= read line || [ -n "$line" ]; do
      if [[ "$line" == "#"* || "$line" == "" ]]; then
         continue
      fi
      #echo "$line"
      key=$(echo $line | cut -d'=' -f1)
      value=$(echo $line | cut -d'=' -f2 | sed 's/"//g' | sed 's/\//\\\//g')
      #echo "value:$value"
      #echo "sed -i -r 's/$key/$value/g' $NEW_YML"
      sed -i -r "s/$key/$value/g" $NEW_YML_PATH
  done < $TAP_ENV

  echo "Replaced values to $NEW_YML_PATH"
}


function copy_if_not_exist {
  SRC_FILE_PATH=$1
  DEST_FOLDER=$2
  SRC_FILENAME=$(echo $SRC_FILE_PATH | rev | cut -d'/' -f1 | rev)
  if [ -f $DEST_FOLDER/$SRC_FILENAME ]; then
    echo "Skip Coping. File already exist: $DEST_FOLDER/$SRC_FILENAME "
  else
    echo "Coping $SRC_FILENAME to $DEST_FOLDER"
    cp $SRC_FILE_PATH $DEST_FOLDER/
  fi
}