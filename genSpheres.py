from random import randrange, uniform

# first num inclusive, second is exclusive

for i in range(32):
    print(
        """{.radius = 1.0,.center = {%d, 0, %d},.color = {%d, %d, %d},.specular = %d,.reflectiveness = """
        % (
            randrange(-30, 30),
            randrange(10, 50),
            randrange(0, 255),
            randrange(0, 255),
            randrange(0, 255),
            randrange(0, 1000),
        )
        + str(uniform(0.05, 0.95))
        + "},"
    )
