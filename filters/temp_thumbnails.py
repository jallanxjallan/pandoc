import panflute as pf
from PIL import Image
from pathlib import Path
import tempfile

THUMBNAIL_DIR = Path("/tmp/thumbnails")
THUMBNAIL_SIZE = (150, 150)

def create_thumbnail(original_path):
    """
    Create a thumbnail for the given image and return the path to the thumbnail.
    """
    # Ensure the thumbnail directory exists
    THUMBNAIL_DIR.mkdir(parents=True, exist_ok=True)

    try:
        # Generate a unique file name in the thumbnail directory
        with tempfile.NamedTemporaryFile(dir=THUMBNAIL_DIR, suffix=".jpg", delete=False) as tmp_file:
            thumbnail_path = Path(tmp_file.name)

        # Open the original image and create a thumbnail
        with Image.open(original_path) as img:
            img.thumbnail(THUMBNAIL_SIZE)
            img.save(thumbnail_path)

        return str(thumbnail_path)

    except Exception as e:
        pf.debug(f"Error creating thumbnail for {original_path}: {e}")
        return None

def process_image(elem, doc):
    """
    Process Image elements in the document.
    """
    if isinstance(elem, pf.Image):
        original_path = Path(elem.url)

        # Skip processing if the file doesn't exist locally
        if not original_path.exists():
            pf.debug(f"Original image not found: {original_path}")
            return

        # Create a thumbnail and update the element's URL
        thumbnail_path = create_thumbnail(original_path)
        if thumbnail_path:
            elem.url = thumbnail_path

def main(doc=None):
    """
    Main function to apply the filter.
    """
    return pf.run_filter(process_image, doc=doc)

if __name__ == "__main__":
    main()
