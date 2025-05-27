// Given a row and a column, find the index of the tile in the tile list
// credit to slightknack for the original code of this function
// https://github.com/slightknack/scrabble/blob/master/src/main.zig
pub fn toIndex(
    x: i32,
    y: i32,
    cols: usize,
    rows: usize,
) ?usize {
    if (0 > x or x >= cols) {
        return null;
    }
    if (0 > y or y >= rows) {
        return null;
    }
    const index: usize = @intCast(y * @as(i32, @intCast(cols)) + x);

    return index;
}
