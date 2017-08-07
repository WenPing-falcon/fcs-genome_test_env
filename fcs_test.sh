#!/bin/bash

source common.sh
source setting.sh
source fcs_genome.sh

check () {
  if [[ $# -ne 1 && $# -n 2 ]]; then
    echo "Usage: binary [function]"
    exit 0
  fi
  local bin=$1

  which $bin &> /dev/null
  if [ "$?" -gt 0 ]; then
    echo "Cannot find \'$bin\' in PATH"
    exit -1
  fi

  if [ $bin = "fcs-genome" ]; then
    if [ $# = 2 ]; then
      tool_mode=1
    fi
  elif [ $bin = "XXX" ]; then
    echo "Usage: xxx"
  else
    echo "binnary is not in test list"
  fi
}

db_dir=""
db_samples=("" "" "" "")
tmp_dir=""

check $*

start_ts=$(date +%s)
for sample in db_samples; do
  if [ ! -z $tool_mode ]; then
    if [ $tool_mode = "align" ]; then
      fcs_genome_align sample "${tmp_dir}/${sample}-align.log"
      if [ $? = 0 ]; then
        rm -rf ${tmp_dir}/${sample}
      fi
    elif [ $tool_mode = "markdup" ]; then
      fcs_genome_markdup sample "${tmp_dir}/${sample}-markdup.log"
      if [ $? = 0 ]; then
        rm -rf ${tmp_dir}/${sample}.bam
      fi
    elif [ $tool_mode = "bqsr" ]; then
      fcs_genome_bqsr sample "${tmp_dir}/${sample}-bqsr.log"
      if [ $? = 0 ]; then
        rm -rf ${tmp_dir}/${sample}.recal.bam
      fi
    elif [ $tool_mode = "htc" ]; then
      fcs_genome_htc sample "${tmp_dir}/${sample}-htc.log"
    else
      echo "tool name wrong"
      exit -1
    fi
  else
    fcs_genome_align sample "${tmp_dir}/${sample}-align.log"
    if [ $? = -1 ]; then
      continue
    fi
    fcs_genome_markdup sample "${tmp_dir}/${sample}-markdup.log"
    if [ $? = -1 ]; then
      continue
    fi
    fcs_genome_bqsr sample "${tmp_dir}/${sample}-bqsr.log"
    if [ $? = -1 ]; then
      continue
    fi
    fcs_genome_htc sample "${tmp_dir}/${sample}-htc.log"
    if [ $? = -1 ]; then
      continue
    fi
    rm -rf ${tmp_dir}/${sample}.bam
    rm -rf ${tmp_dir}/${sample}.recal.bam

    precision=$(vcfdiff ${db_dir}/${sample}.vcf $tmp_dir/${sample}.vcf|sed -n '2,2p'|awk '{print $NF}')
    echo "${sample} presicion ${prefision}"
  fi
  
done

end_ts=$(date +%s)
log_info "finish in $((end_ts - start_ts)) seconds"



