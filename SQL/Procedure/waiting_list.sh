#!/bin/bash

# Redis CLI
REDIS_CLI="redis-cli"
STORE_ID=1

# 함수 정의
function add_user_to_waiting_list {
    USER_ID=$1
    $REDIS_CLI RPUSH waiting_list:$STORE_ID $USER_ID
    echo "사용자 $USER_ID 가 대기열 $STORE_ID 에 추가되었습니다."
}

function remove_user_from_waiting_list {
    USER_ID=$1
    $REDIS_CLI LREM waiting_list:$STORE_ID 0 $USER_ID
    echo "사용자 $USER_ID 가 대기열 $STORE_ID 에서 삭제되었습니다."
}

function process_next_user_in_waiting_list {
    USER_ID=$($REDIS_CLI LPOP waiting_list:$STORE_ID)
    if [ -n "$USER_ID" ]; then
        echo "대기열 $STORE_ID 에서 사용자 $USER_ID 를 처리 중입니다."
    else
        echo "대기열 $STORE_ID 이 비어 있습니다."
    fi
}

function get_waiting_list {
    LIST=$($REDIS_CLI LRANGE waiting_list:$STORE_ID 0 -1)
    if [ -z "$LIST" ]; then
        echo "대기열 $STORE_ID 이 비어 있습니다."
        return
    fi

    echo "대기열 순서:"
    INDEX=1
    for USER_ID in $LIST; do
        echo "$INDEX) $USER_ID"
        INDEX=$((INDEX + 1))
    done
}

function get_user_position {
    USER_ID=$1
    LIST=$($REDIS_CLI LRANGE waiting_list:$STORE_ID 0 -1)
    if [ -z "$LIST" ]; then
        echo "대기열 $STORE_ID 이 비어 있습니다."
        return
    fi

    INDEX=1
    for ID in $LIST; do
        if [ "$ID" == "$USER_ID" ]; then
            echo "사용자 $USER_ID 의 대기열 순서는 $INDEX 번째 입니다."
            return
        fi
        INDEX=$((INDEX + 1))
    done

    echo "사용자 $USER_ID 는 대기열에 없습니다."
}

# 테스트 시작
echo "=== 대기열 테스트 시작 ==="

# 1. 사용자 추가
add_user_to_waiting_list 1001
add_user_to_waiting_list 1002
add_user_to_waiting_list 1003
add_user_to_waiting_list 1004
add_user_to_waiting_list 1005
add_user_to_waiting_list 1006
add_user_to_waiting_list 1007
add_user_to_waiting_list 1008
add_user_to_waiting_list 1009
add_user_to_waiting_list 1010

# 2. 대기열 조회
echo
echo "=== 대기열 상태 조회 ==="
get_waiting_list

# 3. 특정 사용자의 순서 확인
echo
echo "=== 특정 사용자의 순서 확인 ==="
get_user_position 1002

# 4. 대기열의 다음 사용자 처리
echo
echo "=== 다음 사용자 처리 ==="
process_next_user_in_waiting_list

# 5. 대기열 조회
echo
echo "=== 대기열 상태 조회 ==="
get_waiting_list

# 6. 다시 특정 사용자의 순서 확인
echo
echo "=== 특정 사용자의 순서 확인 ==="
get_user_position 1002

# 테스트 종료
echo
echo "=== 대기열 테스트 종료 ==="
