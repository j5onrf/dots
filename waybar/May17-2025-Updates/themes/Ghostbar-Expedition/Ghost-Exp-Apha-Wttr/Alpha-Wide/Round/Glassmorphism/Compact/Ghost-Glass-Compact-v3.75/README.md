# Border Gradients
![FullScreen-2025-07-07_19-30-28](https://github.com/user-attachments/assets/918430a6-56c5-4bcd-8117-6841ba0995df)

`````
general {
    border_size = 2
    gaps_in = 5
    gaps_out = 10

    # MODIFIED: Uses an 8-point gradient to place a color at each corner and make
    # the space between them transparent.
    col.active_border = $primary rgba(00000000) $primary rgba(00000000) $primary rgba(00000000) $primary rgba(00000000) 45deg

    # MODIFIED: Does the same for inactive windows using $outline color.
    col.inactive_border = $outline rgba(00000000) $outline rgba(00000000) $outline rgba(00000000) $outline rgba(00000000) 45deg
}
