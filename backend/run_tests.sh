#!/bin/bash
# CallCraft Backend Test Runner

echo "========================================"
echo "CallCraft Backend Test Suite"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0.32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run pytest with coverage
pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html

TEST_RESULT=$?

echo ""
echo "========================================"
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo "Coverage report: htmlcov/index.html"
else
    echo -e "${RED}✗ Some tests failed${NC}"
fi
echo "========================================"

exit $TEST_RESULT
