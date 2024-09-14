// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");
const std = @import("std");

const Ball = struct {
    position: rl.Vector2,
    speed_x: f32,
    speed_y: f32,
    left_racket: *rl.Rectangle,
    right_racket: *rl.Rectangle,
    const radius = 10;

    pub fn draw(self: @This()) void {
        rl.drawCircleV(self.position, 10, rl.Color.white);
    }

    pub fn update(self: *@This()) void {
        self.position.x += self.speed_x;
        self.position.y += self.speed_y;

        if ((rl.checkCollisionCircleRec(self.position, radius, self.left_racket.*) and self.position.x >
            self.left_racket.x + self.left_racket.width) or
            (rl.checkCollisionCircleRec(self.position, radius, self.right_racket.*) and self.position.x <
            self.right_racket.x + self.right_racket.width))
        {
            self.speed_x = -self.speed_x;
        }
        if (rl.checkCollisionCircleRec(self.position, radius, .{ .x = 0, .y = 0, .width = screenWidth, .height = 1 }) or rl.checkCollisionCircleRec(self.position, radius, .{ .x = 0, .y = screenHeight, .width = screenWidth, .height = 1 })) {
            self.speed_y = -self.speed_y;
        }
        if (self.position.x > screenWidth) {
            l_score += 1;
            self.position = .{ .x = screenWidth / 2, .y = screenHeight / 2 };
        } else if (self.position.x < 0) {
            r_score += 1;
            self.position = .{ .x = screenWidth / 2, .y = screenHeight / 2 };
        }
    }
};

const screenWidth = 800;
const screenHeight = 450;
var l_score: u32 = 0;
var r_score: u32 = 0;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.initWindow(screenWidth, screenHeight, "Pong");
    rl.disableCursor();
    defer rl.closeWindow(); // Close window and OpenGL context
    defer rl.enableCursor();

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var racket_1 = rl.Rectangle.init(25, screenHeight / 2, 15, 100);
    var racket_2 = rl.Rectangle.init(screenWidth - 25, screenHeight / 2, 15, 100);
    const speed: i32 = 400;

    const rand_vel = [2]f32{ -7, 7 };
    var ball = Ball{
        .position = .{ .x = screenWidth / 2, .y = screenHeight / 2 },
        .speed_x = rand_vel[@bitCast(@as(i64, rl.getRandomValue(0, 1)))],
        .speed_y = rand_vel[@bitCast(@as(i64, rl.getRandomValue(0, 1)))],
        .left_racket = &racket_1,
        .right_racket = &racket_2,
    };

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        racket_1.y += (bool_2_float(rl.isKeyDown(.key_s)) - bool_2_float(rl.isKeyDown(.key_w))) * speed * rl.getFrameTime();
        racket_2.y += (bool_2_float(rl.isKeyDown(.key_down)) - bool_2_float(rl.isKeyDown(.key_up))) * speed * rl.getFrameTime();
        racket_1.y = std.math.clamp(racket_1.y, 0, screenHeight - 100);
        racket_2.y = std.math.clamp(racket_2.y, 0, screenHeight - 100);
        ball.update();
        //----------------------------------------------------------------------------------
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        //Ball
        ball.draw();
        //Rackets
        rl.drawRectangleRec(racket_1, rl.Color.white);
        rl.drawRectangleRec(racket_2, rl.Color.white);
        rl.drawLine(screenWidth / 2, 0, screenWidth / 2, screenHeight, rl.Color.light_gray);
        rl.drawText(rl.textFormat("%d - %d", .{ l_score, r_score }), (screenWidth / 2) - 40, 25, 35, rl.Color.white);
        //----------------------------------------------------------------------------------
        //Physics
        //----------------------------------------------------------------------------------
    }
}

pub inline fn bool_2_float(value: bool) f32 {
    return if (value) 1 else 0;
}
