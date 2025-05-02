#!/usr/bin/env python

import os
import sys

import django

sys.path.append('/opt/netbox/netbox')
# Adapter ce chemin selon ton installation NetBox
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "netbox.settings")

# Setup Django
django.setup()

from core.models import ObjectChange

def cleanup_object_changes():
    count = ObjectChange.objects.count()
    if count == 0:
        print("Aucun historique à supprimer.")
        return

    deleted, _ = ObjectChange.objects.all().delete()
    print(f"{deleted} entrées d'historique supprimées.")

if __name__ == "__main__":
    cleanup_object_changes()
