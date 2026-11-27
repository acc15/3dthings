"""SMD -> DIP adapter clip.

Port of ``smd_adapter_clip.scad`` to build123d (algebra mode).

The clip holds the adapter PCB and surrounds the SMD footprint.  It is built
from a 2D cross-section (the "omega" profile that wraps around the board)
extruded along Y, with a rectangular cut-out for the chip.  Lead contacts are
built as separate solids and composed with plain algebra: add ``feet()`` to
the body or cut ``seats()`` into it.
"""
import math
from dataclasses import dataclass

from build123d import *
from ocp_vscode import show

# 0.1" pin pitch: the adapter footprints are counted in these units.
DIP_PITCH = 2.54

BOARD_THICKNESS = 1.5

THICKNESS = 2.0
# Space between the board top and the cavity ceiling.  The foot pads fill it
# completely, the silicone strip protrudes into it.
CONTACT_HEIGHT = 0.4
LOCK_HEIGHT = 0.4
# Foot pads are as wide as the free PCB band allows, but no more than this.
FOOT_WIDTH_MAX = 1.5
# Flat silicone contact strip: ~1.0 mm thick, 0.6-0.7 mm wide.  It is a
# press fit into the 0.5 x 0.6 mm pocket, so no glue is needed.
SEAT_WIDTH = 0.5
SEAT_DEPTH = 0.6
ANGLE = 45.0
# Horizontal run of each cavity wall per unit of height.
TAPER = math.tan(math.radians(ANGLE))

BOARD_HALF = BOARD_THICKNESS / 2
# Cavity ceiling, which is also the underside of the bridge.
TOP_Z = BOARD_HALF + CONTACT_HEIGHT
BOTTOM_Z = -BOARD_HALF - LOCK_HEIGHT
# Bridge underside, normal pointing into the cavity: "+" adds a pad downwards,
# "-" cuts a pocket upwards.
BRIDGE = Plane(origin=(0, 0, TOP_Z), x_dir=(1, 0, 0), z_dir=(0, 0, -1))


@dataclass(frozen=True)
class AdapterSize:
    """Dimensions of one adapter, all in mm.

    Both tuples are ``(length along X, width along Y)``: X runs along the
    pin rows and Y across them.  ``clip`` is the board-side footprint.
    ``chip[0]`` is the SMD body length; ``chip[1]`` is the distance between
    the spots where the contacts press the leads on either side.  It also
    sizes the chip window across Y, so it must clear the package body.
    """

    clip: tuple[float, float]
    chip: tuple[float, float]

    @property
    def band_y(self) -> float:
        """Free PCB strip on each side of the chip, across Y."""
        return (self.clip[1] - self.chip[1]) / 2


# name -> (clip footprint, chip cut-out), mirroring the SCAD ``sizes`` table
PRESETS: dict[str, AdapterSize] = {
    "sot23": AdapterSize(clip=(3 * DIP_PITCH, 2 * DIP_PITCH), chip=(3.0, 1.7)),
    "sop8": AdapterSize(clip=(4 * DIP_PITCH, 3 * DIP_PITCH), chip=(5.0, 5.1)),
    "sop14": AdapterSize(clip=(7 * DIP_PITCH, 4 * DIP_PITCH), chip=(9.0, 5.1)),
}

# The adapter the clip is generated for.


def clip_profile() -> Sketch:
    """Material cross-section: the cavity grown outward by THICKNESS.

    The cavity is the slot the adapter PCB sits in: ``PRESET.clip[0]`` is its
    width at the board faces, and the walls taper at ``ANGLE`` away from the
    widest mid-plane.  A mitered 2D offset (``Kind.INTERSECTION``) gives
    exactly the outer contour that used to be computed by hand with
    ``2 / cos(angle)`` and ``tan(45 - angle / 2)``.  The offset also grows
    below the open slot, so that part is trimmed off flush with the lip.
    """
    half = PRESET.clip[0] / 2
    # Right half bottom to top, then its mirror top to bottom: the contour is
    # counter-clockwise, so the face normal is +Z.
    side = [
        (half - LOCK_HEIGHT * TAPER, BOTTOM_Z),
        (half + BOARD_HALF * TAPER, 0.0),
        (half - CONTACT_HEIGHT * TAPER, TOP_Z),
    ]
    cavity = Polygon(*(side + [(-x, z) for x, z in reversed(side)]))

    grown = offset(cavity, THICKNESS, kind=Kind.INTERSECTION)
    bbox = grown.bounding_box()
    # Trim the part of the offset that grew below the slot opening.
    keep_above_slot = Pos(0, BOTTOM_Z) * Rectangle(
        bbox.size.X,
        bbox.max.Y - BOTTOM_Z,
        align=(Align.CENTER, Align.MIN),
    )

    return Sketch((grown & keep_above_slot) - cavity)


def clip() -> Part:
    """Clip body around the adapter board, with the chip window cut out."""
    part = extrude(
        Plane.XZ * clip_profile(),
        amount=PRESET.clip[1] / 2,
        both=True,
    )

    # The window cuts only the bridge; below it the cavity is already open.
    part -= extrude(
        BRIDGE * Rectangle(PRESET.chip[0], PRESET.chip[1]),
        amount=-THICKNESS,
    )
    return Part(part)


def _contacts(width: float, amount: float) -> Part:
    """Two lead contacts on the bridge underside, mirrored across the chip.

    Both start at the chip window edge and extend outward by ``width`` into
    the exposed PCB strip, so they must fit inside that band.  ``amount``
    grows along the cavity-facing bridge normal: a positive value adds
    material downwards, a negative one cuts upwards.
    """
    band_y = PRESET.band_y
    if not 0 < width <= band_y:
        raise ValueError(
            f"{width:.2f} mm contacts do not fit in a {band_y:.2f} mm band"
        )

    # Full cavity width at the bridge underside (the profile's top edge).
    strip_x = PRESET.clip[0] - 2 * CONTACT_HEIGHT * TAPER
    center_y = PRESET.chip[1] / 2 + width / 2

    return extrude(
        BRIDGE * Sketch(
            Pos(0, sign * center_y) * Rectangle(strip_x, width)
            for sign in (1, -1)
        ),
        amount=amount,
    )


def feet() -> Part:
    """Rigid pads on the bridge underside, pressing the leads onto the PCB."""
    return _contacts(min(FOOT_WIDTH_MAX, PRESET.band_y), CONTACT_HEIGHT)


def seats() -> Part:
    """Pockets in the bridge underside for a silicone contact strip.

    A ~1.0 mm thick silicone strip (0.6-0.7 mm wide, cut to ``strip_x``) is
    pressed into each pocket: the press fit holds it without glue, it
    protrudes ~0.4 mm and is compressed ~0.2 mm by the SMD leads.
    """
    return _contacts(SEAT_WIDTH, -SEAT_DEPTH)


def printable(part: Part) -> Part:
    """Flip the part so the open side faces down for printing."""
    return Rot(180, 0, 0) * Part(part)


for name, preset in PRESETS.items():
    NAME = name
    PRESET = preset
    export_step(printable(Part(clip() - seats())), f"{NAME}_seats.step")

for name, preset in PRESETS.items():
    NAME = name
    PRESET = preset
    export_step(printable(Part(clip() + feet())), f"{NAME}_feet.step")

# show(part)
# export_step(part, f"{NAME}_seats.step")    # pockets for a silicone contact strip
# show(clip() + feet())   # rigid PETG pads
# show(clip())            # bare clip
