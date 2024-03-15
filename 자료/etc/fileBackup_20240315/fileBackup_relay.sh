#!/bin/bash
echo "fileBackup_relay.sh Script START"

# 기본 설정 변수
base_dirs=("/kftcedi/auto_file/rcv" "/kftcedi/auto_file/snd" "/kbedi/edi_file" "/cBox/CBoxColl/coll_file/send_data/backup")
backup_suffix="back"

# 백업대상 파일연도 입력
read -p "백업 파일연도(ex:2023): " backup_yr
echo "파일연도 = $backup_yr"
read -p "백업 시작일자(ex:20230101): " start_dt
echo "시작일자 = $start_dt"
read -p "백업 종료일자(ex:20240101): " end_dt
echo "종료일자 = $end_dt"

# 백업 디렉토리 생성 함수
create_backup_dirs() {
    for dir in "${base_dirs[@]}"; do
        mkdir -p "${dir}/${backup_suffix}_${backup_yr}/"
        echo "${dir}/${backup_suffix}_${backup_yr}/ 백업 디렉토리 생성"
    done
}

# 파일 및 디렉토리 이동 함수
# find 명령어를 사용하여 백업 기간 내에 수정된 파일 및 디렉토리를 찾습니다.
# -mindepth 1 -maxdepth 1 옵션은 최상위 경로에 직접 위치한 항목들만 대상으로 한다는 것을 의미합니다.
# 찾아낸 항목들을 백업 연도에 해당하는 디렉토리로 이동시킵니다.
# 이동된 항목에 대해 로그 메시지를 출력합니다.
move_files_dirs() {
    for dir in "${base_dirs[@]}"; do
        local src_path="${dir}"
        local dest_path="${src_path}/${backup_suffix}_${backup_yr}"

        # YYYYMMDD 패턴 디렉토리 및 파일 이동
        find "$src_path" -mindepth 1 -maxdepth 1 \( -type f -or -type d \) -newermt $start_dt ! -newermt $end_dt -exec mv {} "$dest_path/" \;

        echo "Moved items to $dest_path"
    done
}

# 백업 디렉토리 생성 및 파일, 디렉토리 이동 실행
create_backup_dirs
move_files_dirs

echo "fileBackup_relay.sh Script END"