# Instagram Clone Database Structure

Here's the structured overview of your Instagram clone database schema:

## Database
- **ig_clone** - The main database for the Instagram clone application

## Tables

### 1. users
- Stores user account information
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW ()
);
```

### 2. photos
- Stores photo metadata and links to image files
```sql
CREATE TABLE photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(355) NOT NULL,
    user_id INT NOT NULL,
    created_dat TIMESTAMP DEFAULT NOW (),
    FOREIGN KEY (user_id) REFERENCES users (id)
);
```

### 3. comments
- Stores user comments on photos
```sql
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comment_text VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    photo_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW (),
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (photo_id) REFERENCES photos (id)
);
```

### 4. likes
- Tracks which users have liked which photos (many-to-many relationship)
```sql
CREATE TABLE likes (
    user_id INT NOT NULL,
    photo_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW (),
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (photo_id) REFERENCES photos (id),
    PRIMARY KEY (user_id, photo_id)
);
```

### 5. follows
- Tracks follower/followee relationships between users
```sql
CREATE TABLE follows (
    follower_id INT NOT NULL,
    followee_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW (),
    FOREIGN KEY (follower_id) REFERENCES users (id),
    FOREIGN KEY (followee_id) REFERENCES users (id),
    PRIMARY KEY (follower_id, followee_id)
);
```

### 6. tags
- Stores hashtag information
```sql
CREATE TABLE tags (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW ()
);
```

### 7. photo_tags
- Junction table linking photos to tags (many-to-many relationship)
```sql
CREATE TABLE photo_tags (
    photo_id INT NOT NULL,
    tag_id INT NOT NULL,
    FOREIGN KEY (photo_id) REFERENCES photos (id),
    FOREIGN KEY (tag_id) REFERENCES tags (id),
    PRIMARY KEY (photo_id, tag_id)
);
```

## Relationships
1. **One-to-Many**:
   - Users to Photos (one user can have many photos)
   - Users to Comments (one user can make many comments)
   - Photos to Comments (one photo can have many comments)

2. **Many-to-Many**:
   - Users to Photos through Likes (users can like many photos, photos can be liked by many users)
   - Users to Users through Follows (users can follow many users, users can be followed by many users)
   - Photos to Tags through Photo_Tags (photos can have many tags, tags can be on many photos)

This structure provides a solid foundation for an Instagram-like application with all the core social media features.