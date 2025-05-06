#!/usr/bin/env python

import os
import sys

import django

# Chemin vers le code NetBox
sys.path.append('/opt/netbox/netbox')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'netbox.settings')
django.setup()

from extras.models import ImageAttachment

MEDIA_PATH = '/opt/netbox/netbox/media/image-attachments'

def cleanup_orphaned_images():
    # Liste des fichiers réellement utilisés par NetBox
    db_images = set(
        os.path.basename(attachment.image.name)
        for attachment in ImageAttachment.objects.all()
        if attachment.image and hasattr(attachment.image, 'name')
    )

    # Liste des fichiers présents physiquement
    try:
        fs_images = set(os.listdir(MEDIA_PATH))
    except FileNotFoundError:
        print(f"Media path not found: {MEDIA_PATH}")
        return

    orphaned = fs_images - db_images

    for filename in orphaned:
        path = os.path.join(MEDIA_PATH, filename)
        print(f"Removing orphaned image: {filename}")
        os.remove(path)

if __name__ == "__main__":
    cleanup_orphaned_images()
