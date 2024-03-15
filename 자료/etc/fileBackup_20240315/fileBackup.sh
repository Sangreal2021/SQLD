#/bin/bash
# 통합자금관리시스템 파일 백업 관리하는 쉘 스크립트
# 운영 서버용
# 백업대상 파일경로의 파일들을 파일생성관리 연도의 백업 폴더로 이동 시킨다
# /home/appian_storage/FILE/AUTO
# /home/appian_storage/FILE/EDI
#
# USAGE= (사용예시)
# 백업 파일연도 : backup_yr = 2023
# 백업 시작일자 : start_dt = 20230101
# 백업 종료일자 : end_dt = 20240101

echo "fileBackup.sh Script START"

# 기본 설정 변수
base_dir="/home/appian_storage/FILE"
backup_suffix="bak"
snd_dir="snd"
rcv_dir="rcv"

# 대상 디렉토리 설정 변수 (새로운 경로 필요시 dirs에 추가)
# 새로 추가할 디렉토리명이 기존에 존재하는지 확인
dirs=("AUTO" "EDI")

# 백업 대상 디렉토리(동적 생성)
declare -A backup_dirs
for dir in "${dirs[@]}"; do
    if [[ ! -d "$base_dir/$dir" ]]; then
        echo "$dir 백업 디렉토리 생성"
        mkdir -p "$base_dir/$dir"
    fi
    backup_dirs["$dir"]="$base_dir/$dir"
done

# 백업대상 파일연도 입력
read -p "백업 파일연도(ex:2023): " backup_yr
echo "파일연도 = $backup_yr"

# 백업대상 기간 입력
read -p "백업 시작일자(ex:20230101): " start_dt
echo "시작일자 = $start_dt"
read -p "백업 종료일자(ex:20240101): " end_dt
echo "종료일자 = $end_dt"

# 백업 디렉토리 생성 함수
create_backup_dirs() {
    for key in "${!backup_dirs[@]}"; do
        mkdir -p "${backup_dirs[$key]}/${backup_suffix}_${backup_yr}/${snd_dir}"
        mkdir -p "${backup_dirs[$key]}/${backup_suffix}_${backup_yr}/${rcv_dir}"
        echo "$key 백업 디렉토리 생성"
    done
}

# 파일 이동 함수
move_files() {
    local pattern="$1"
    for key in "${!backup_dirs[@]}"; do
        local src_path="${backup_dirs[$key]}"
        local dest_path="${src_path}/${backup_suffix}_${backup_yr}/${snd_dir}"
        local exclude_path="${src_path}/${backup_suffix}_${backup_yr}"
        find "$src_path" -type f -newermt $start_dt ! -newermt $end_dt -name "$pattern" -not -path "$exclude_path/*" -exec mv {} "$dest_path" \;
    done
    echo "파일 이동 완료"
}

# 디렉토리 이동 함수
move_dir() {
    for key in "${!backup_dirs[@]}"; do
        local src_path="${backup_dirs[$key]}"
        for dir in "$src_path"/*; do
            if [[ -d "$dir" ]]; then
                dir_date=$(basename "$dir")
                if [[ "$dir_date" =~ ^[0-9]{8}$ && "$dir_date" > "$start_dt" && "$dir_date" < "$end_dt" ]]; then
                    mv "$dir" "${src_path}/${backup_suffix}_${backup_yr}/${rcv_dir}"
                    echo "Moved $dir to ${src_path}/${backup_suffix}_${backup_yr}/${rcv_dir}"
                fi
            fi
        done
    done
}

# 백업 디렉토리 생성 및 파일, 디렉토리 이동 실행
create_backup_dirs
move_files "E*"
move_files "ktcu*"
move_dir

echo "fileBackup.sh Script END"