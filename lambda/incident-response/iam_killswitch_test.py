import os
import sys
import json
import unittest
from unittest.mock import patch, MagicMock


# Now we can safely import the module by its filename
import iam_killswitch

class TestIAMKillSwitch(unittest.TestCase):
    def setUp(self):
        with open("synthetic_guardduty_event.json") as f:
            self.event = json.load(f)

    @patch("iam_killswitch.iam_client")
    def test_successful_extraction_and_containment(self, mock_iam):
        # Mock successful IAM update call
        mock_iam.update_access_key.return_value = {}

        response = iam_killswitch.lambda_handler(self.event, None)

        # Verify parsing assertions
        self.assertEqual(response["statusCode"], 200)
        mock_iam.update_access_key.assert_called_once_with(
            UserName="test-compromised-user",
            AccessKeyId="AKIAIOSFODNN7EXAMPLE",
            Status="Inactive"
        )

    def test_missing_access_key_data(self):
        # Corrupt event detail
        corrupted_event = {"detail": {"resource": {"accessKeyDetails": {}}}}
        response = iam_killswitch.lambda_handler(corrupted_event, None)

        self.assertEqual(response["statusCode"], 400)

if __name__ == "__main__":
    unittest.main()