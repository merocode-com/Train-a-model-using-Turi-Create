import turicreate as tc 
import os

# This is a link to a dataset that can be used to train that model
# https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/dogImages.zip

# Load training data
train_data = tc.image_analysis.load_images('dogImages/train', with_path=True)
train_data['label'] = train_data['path'].apply(lambda path: os.path.dirname(path).split('/')[-1])

# View labels and some data
result = train_data.groupby('label', [tc.aggregate.COUNT])
result.print_rows(num_rows=133, num_columns=3)
train_data.save('dog_training.sframe')
train_data[:10].explore()

# Load test data
test_data = tc.image_analysis.load_images('dogImages/test', with_path=True)
test_data['label'] = test_data['path'].apply(lambda path: os.path.dirname(path).split('/')[-1])

# Create and train the model
# That trains the image classifiers using resnet-50 model 
model = tc.image_classifier.create(train_data, target='label', max_iterations=30)

# Uncomment this line to train the image classifier using squeezenet_v1.1 model
# model = tc.image_classifier.create(train_data, target='label', max_iterations=50, model='squeezenet_v1.1')

# Prediction
predictions = model.predict(test_data)
metrics = model.evaluate(test_data)
print(metrics['accuracy'])

model.save('dog_classifier.model')

model.export_coreml('dog_classifier.mlmodel')

