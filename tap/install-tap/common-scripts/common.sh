#!/bin/bash
set -e



## this is for this program only.
## check debug flag
for i in "$@"; do
  if [ "$i" == "--debug" ]; then
    DEBUG="y"
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
  echo "    cp -r install-tap/tap-env.template /any/path/tap-env"
  echo "    export TAP_ENV=/path/to/tap-env > ~/.tapconfig"
  echo ""
}


function set_tapconfig {
  DEFAULT_ENV_PATH="$SCRIPTDIR/tap-env" 
  ENV_PATH=${1:-$DEFAULT_ENV_PATH}  

  ABS_ENV_PATH="$( cd "$( dirname "${ENV_PATH[0]}" )" && pwd )/$(basename -- $ENV_PATH)"

  if [ ! -f $ABS_ENV_PATH ]; then
    echo "Coping $SCRIPTDIR/tap-env.template to $ABS_ENV_PATH"
    cp $SCRIPTDIR/tap-env.template $ABS_ENV_PATH
  fi
  echo "export TAP_ENV=$ABS_ENV_PATH"
  echo "export TAP_ENV=$ABS_ENV_PATH" > ~/.tapconfig
}

function load_env_file {
  DEFAULT_ENV=$1

  if [ -f ~/.tapconfig ]; then
    echo "Loading TAP_ENV from ~/.tapconfig"
    source ~/.tapconfig
  fi

  ENV=${TAP_ENV:-$DEFAULT_ENV}
  if [ ! -f $ENV ]; then
    echo "ERROR: Env file not found $ENV"
    print_help_customizing
    exit 1
  fi
  echo "Using env from '$ENV'"
  export ENV=$ENV
  source $ENV
}

function print_debug {
  if [ "$DEBUG" == "y" ]; then
    echo "  DEBUG: $1"  
  fi
}


function yml_arg_not_exist {
  for i in "$@"; do
    case $i in
      -f=*|--file=*|-f|--file)
      return 1
      ;;
    esac
    return 0
  done
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

## replace template with "tap-env" and
## create a new file under /tmp
function generate_yml_if_template_yml {
  YML=$1
  if [[ ! "$YML" == *"TEMPLATE"* ]]; then
    ## it is not template yml. 
    echo "$YML"
    return 
  fi
  yml_file=$(echo $YML | rev | cut -d'/' -f1 | rev)
  NEW_YML=$(echo $yml_file | sed 's/TEMPLATE/CONVERTED/g')
  NEW_YML_PATH="/tmp/${NEW_YML}"
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
  done < $TANZU_ENV

  echo "$NEW_YML_PATH"
}
