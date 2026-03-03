"""
Test script to verify PyJWT authentication is working correctly
Run this after installing requirements-python313.txt
"""
import sys
from datetime import timedelta

def test_imports():
    """Test that all required packages can be imported"""
    print("Testing imports...")

    try:
        import jwt
        print("✓ PyJWT imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import PyJWT: {e}")
        return False

    try:
        from jwt.exceptions import InvalidTokenError
        print("✓ InvalidTokenError imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import InvalidTokenError: {e}")
        return False

    try:
        from passlib.context import CryptContext
        print("✓ passlib imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import passlib: {e}")
        return False

    return True


def test_password_hashing():
    """Test password hashing functionality"""
    print("\nTesting password hashing...")

    try:
        from app.core.security import get_password_hash, verify_password

        # Hash a password
        password = "testpassword123"
        hashed = get_password_hash(password)
        print(f"✓ Password hashed: {hashed[:50]}...")

        # Verify correct password
        if verify_password(password, hashed):
            print("✓ Password verification successful")
        else:
            print("✗ Password verification failed")
            return False

        # Verify wrong password fails
        if not verify_password("wrongpassword", hashed):
            print("✓ Wrong password correctly rejected")
        else:
            print("✗ Wrong password was accepted (should fail)")
            return False

        return True
    except Exception as e:
        print(f"✗ Password hashing failed: {e}")
        return False


def test_jwt_tokens():
    """Test JWT token creation and decoding"""
    print("\nTesting JWT tokens...")

    try:
        from app.core.security import create_access_token, decode_access_token

        # Create token
        test_data = {"sub": "user123", "email": "test@example.com"}
        token = create_access_token(test_data)
        print(f"✓ Token created: {token[:50]}...")

        # Decode token
        payload = decode_access_token(token)
        print(f"✓ Token decoded successfully")
        print(f"  - User ID: {payload.get('sub')}")
        print(f"  - Email: {payload.get('email')}")
        print(f"  - Expires: {payload.get('exp')}")

        # Verify payload
        if payload.get("sub") != "user123":
            print("✗ Token payload incorrect")
            return False

        print("✓ Token payload correct")

        # Test token with custom expiration
        token_short = create_access_token(
            {"sub": "user456"},
            expires_delta=timedelta(minutes=5)
        )
        payload_short = decode_access_token(token_short)
        print(f"✓ Token with custom expiration works")

        return True
    except Exception as e:
        print(f"✗ JWT token test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_invalid_token():
    """Test that invalid tokens are rejected"""
    print("\nTesting invalid token handling...")

    try:
        from app.core.security import decode_access_token
        from fastapi import HTTPException

        # Try to decode invalid token
        try:
            decode_access_token("invalid.token.here")
            print("✗ Invalid token was accepted (should fail)")
            return False
        except HTTPException as e:
            if e.status_code == 401:
                print("✓ Invalid token correctly rejected with 401")
                return True
            else:
                print(f"✗ Wrong status code: {e.status_code} (expected 401)")
                return False
    except Exception as e:
        print(f"✗ Invalid token test failed: {e}")
        return False


def test_security_module():
    """Test that security module can be imported from app"""
    print("\nTesting security module import...")

    try:
        from app.core import security
        print("✓ Security module imported from app.core")

        # Check all required functions exist
        required_functions = [
            'verify_password',
            'get_password_hash',
            'create_access_token',
            'decode_access_token',
            'get_current_user_id'
        ]

        for func_name in required_functions:
            if hasattr(security, func_name):
                print(f"✓ Function '{func_name}' exists")
            else:
                print(f"✗ Function '{func_name}' missing")
                return False

        return True
    except Exception as e:
        print(f"✗ Security module import failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Run all tests"""
    print("=" * 60)
    print("PyJWT Authentication Test Suite")
    print("=" * 60)
    print()

    # Check Python version
    print(f"Python version: {sys.version}")
    if sys.version_info < (3, 9):
        print("⚠ Warning: Python 3.9+ recommended")
    print()

    tests = [
        ("Import Test", test_imports),
        ("Password Hashing Test", test_password_hashing),
        ("JWT Token Test", test_jwt_tokens),
        ("Invalid Token Test", test_invalid_token),
        ("Security Module Test", test_security_module),
    ]

    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"\n✗ {test_name} crashed: {e}")
            results.append((test_name, False))
        print()

    # Print summary
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for test_name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status} - {test_name}")

    print()
    print(f"Results: {passed}/{total} tests passed")

    if passed == total:
        print()
        print("🎉 All tests passed! PyJWT authentication is working correctly.")
        print()
        print("Next steps:")
        print("  1. Start the API server: uvicorn app.main:app --reload")
        print("  2. Test the endpoints: python test_api.py")
        print("  3. Check the docs: http://localhost:8000/docs")
        return 0
    else:
        print()
        print("⚠ Some tests failed. Please check the errors above.")
        print()
        print("Troubleshooting:")
        print("  1. Ensure you installed: pip install -r requirements-python313.txt")
        print("  2. Ensure you copied: copy app\\core\\security_pyjwt.py app\\core\\security.py")
        print("  3. Check PYTHON313_FIX.md for detailed instructions")
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
