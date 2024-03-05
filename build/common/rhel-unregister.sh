#!/bin/bash

echo '==> Removing Red Hat subscriptions'
subscription-manager remove --all
subscription-manager unregister
subscription-manager clean
echo '==> Subscription successfully removed'
