#! /bin/sh
# file: ./testContainer.sh

testContainer() {
  RUNNING=$(docker inspect --format '{{.State.Running}}' test)
  assertEquals "container is not Running!" 'true' "${RUNNING}"
  
}

# Load shUnit2.
. ./shunit2