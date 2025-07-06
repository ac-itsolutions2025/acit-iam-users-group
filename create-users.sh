#!/bin/bash

# Define variables
GROUP_NAME="ACIT-HelpDesk"
USERS=(
  "many@ac-itsolutions.net"
  "handerson.a.ntani@ac-itsolutions.net"
  "nelson.t.fultang@ac-itsolutions.net"
  "randolp.a.bame@ac-itsolutions.net"
)

# IAM policies to attach to group
POLICIES=(
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
)

# Create IAM group if it doesn't exist
aws iam get-group --group-name "$GROUP_NAME" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating group: $GROUP_NAME"
  aws iam create-group --group-name "$GROUP_NAME"
else
  echo "Group $GROUP_NAME already exists."
fi

# Attach policies to the group
for policy_arn in "${POLICIES[@]}"; do
  aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$policy_arn"
done

# Loop through each user
for USERNAME in "${USERS[@]}"; do
  # Create IAM user
  echo "Creating user: $USERNAME"
  aws iam create-user --user-name "$USERNAME"

  # Add user to group
  aws iam add-user-to-group --user-name "$USERNAME" --group-name "$GROUP_NAME"

  # Create login profile with a random password (requires password reset on first login)
  PASSWORD="$(openssl rand -base64 16)"
  aws iam create-login-profile \
    --user-name "$USERNAME" \
    --password "$PASSWORD" \
    --password-reset-required

  echo "Temporary password for $USERNAME: $PASSWORD"

  # Attach inline policy to allow password change
  aws iam put-user-policy \
    --user-name "$USERNAME" \
    --policy-name "AllowChangeOwnPassword" \
    --policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "iam:ChangePassword"
          ],
          "Resource": "arn:aws:iam::*:user/${aws:username}"
        }
      ]
    }'
done

echo "All users created and configured."
