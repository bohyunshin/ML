## LGBM parameters 이해하기



이번 글에서는 ML의 대표 모델 중 하나인 Light GBM의 python 구현 parameters를 깊게 파헤쳐본다. 먼저 아래의 페이지를 참고하였음을 밝혀둔다.

* https://neptune.ai/blog/lightgbm-parameters-guide
* https://sites.google.com/view/lauraepp/parameters
* https://lightgbm.readthedocs.io/en/latest/
* https://lightgbm.readthedocs.io/en/latest/Parameters.html
* https://www.programcreek.com/python/example/103517/hyperopt.hp.loguniform :  hyperopt을 이용한 lgbm 파라미터 튜닝
* https://mlexplained.com/2018/01/05/lightgbm-and-xgboost-explained/ : lgbm, xgboost 비교한 글
* https://towardsdatascience.com/what-makes-lightgbm-lightning-fast-a27cf0d9785e : lgbm의 goss 알고리즘에한 글
* https://github.com/microsoft/LightGBM/issues/695#issuecomment-315591634 : imbalance 데이터에서 lgbm tuning 시에 주의해야할 점.

이 중에 두 번째 페이지는 Laurae라는 lightgbm 개발자가 lightgbm와 xgboost의 파라미터를 설명하기 위해 만든 페이지이다. 설명이 매우 자세하고 두 모델의 파라미터를 비교하여 이해하기가 조금 더 수월하다. 본격적으로 살펴보자.



### Gradient Boosting methods: *boosting_type* parameter

>boosting_type (string, optional (default='gbdt')) – ‘gbdt’, traditional Gradient Boosting Decision Tree. ‘dart’, Dropouts meet Multiple Additive Regression Trees. ‘goss’, Gradient-based One-Side Sampling. ‘rf’, Random Forest.

어떤 종류의 gradient boosting 방법을 사용할지 결정하는 파라미터이다. 크게 `gbdt, dart, goss, rf` 옵션이 있다.

* gbdt (gradient boosted decision trees)

  이 방법은 [여기](https://statweb.stanford.edu/~jhf/ftp/trebst.pdf) 에서 제안된,  전통적인 gradient boosting decision tree 방법이다. boosting의 중요한 특징 중 하나인, tree을 week learners로 ensemble하는 특징이 있다. 즉 다시 말해서, 첫 번째 tree가 타겟 변수를 학습하고, 첫 번재 tree가 학습하지 못한 부분을 두 번째 tree가 학습한다. 이런 식으로 tree을 만들어나간다.
  그 다음 tree의 학습이 random forest와는 달리, 그 이전의 tree에 의존하므로 병렬 계산이 불가능하고 따라서 시간이 많이 소요되는 단점이 있다.

* dart (dropout additive regression tree)

  이 방법은 [여기](https://arxiv.org/pdf/1505.01866.pdf) 서 제안된 방법이다. gbdt는 나중에 만들어진 tree의 영향력이 작다는 단점이 있다. 이를 over-specialization 문제라고 하는데, dropout을 통해서 이를 해결하고자 하는 방법이다.

* goss (gradient based one-side sampling)

  lightgbm이 *light* 라는 이름을 붙여준 방법이다. 기존의 gbdt는 계산 시간이 오래 걸리는데, 이러한 단점을 극복하기 위해서  새로운 sampling 기법을 제안한다. 간단히 말해서 gradient가 큰 데이터는 모두 keep하고, 작은 데이터는 랜덤하게 샘플링한다. (one-side sampling이라고 불리는 이유이다.) 이런 식으로 search space을 줄여서 더 빠르게 수렴할 수 있도록 도와준다.

이를 표로 정리하면 아래와 같다.

| boosting 방법 | 요약                                   | 관련 파라미터                                                | 장점        | 단점                                   |
| ------------- | -------------------------------------- | ------------------------------------------------------------ | ----------- | -------------------------------------- |
| gbdt          | 기본값                                 | 딱히 없음                                                    | 안정적임    | over-specialization<br />계산량이 많음 |
| dart          | over-specialization<br />피하기 위해서 | drop_seed<br />xgboost_dart_mode<br />skip_drop<br />max_dropout_rate | 정확도 좋음 | 파라미터가 많음                        |
| goss          | 더 빠른 계산을 위한 sampling           | top_rate: 큰 gradient 보유 비율<br />other_rate: 작은 gradient 보유 비율 | 빠름        | 과적합 우려                            |

lightgbm의 공식 문서를 보면, `rf` 방법도 있다. 이 방법을 사용하면 부스팅이 아니라 random forest처럼 tree을 키운다. 즉, 각각의 tree를 독립적으로 키우는 것이다. 부스팅을 사용하기로 했으면 `rf` 로 할 필요가 없지 않나 싶다.

참고로, lgbm 논문에서는 크게 goss, efb를 제안하였는데, goss는 위 옵션으로 지정하면 되고 efb는 어떻게 지정할지 개인적으로 궁금했다. 구글링 결과, `lgbm.Dataset()` 안에 `enable_bundle` 의 기본 값으로 지정되어 있다고 한다. 이때, dictionary 형태로 넣어야 하는데 `data = lgbm.Dataset(train, train_label, params={'enable_bundle': False})` 와 같이 해주면 된다. [여기](https://github.com/Microsoft/LightGBM/issues/1267) 를 참조하였다.



### Regularziation

부스팅 계열의 모델은 잠재적인 과적합 위험이 있으며 특히 lgbm은 그 위험이 다른 부스팅 계열 모델에 비해서 높다.  그 이유는 lgbm이 **Leaf-wise** 방식으로 tree을 키우는 반면, xgboost는 **Level-wise** 방식으로 tree을 키우기 때문이다. 바로 이러한 알고리즘적인 차이 때문에, lgbm이 수렴 속도가 빠르긴 하지만, 10000개 이하의 데이터에 대해서는 과적합 위험이 있으므로 아예 데이터 개수가 적으면 사용하지 않는 것이 낫다고 한다.

따라서 과적합을 방지하기 위해, 관련 파라미터 튜닝은 필수적이다. lgbm 공식 문서에는 과적합이 의심된다면, 아래 시도를 해보라고 조언해준다.

* 작은 max_bin 사용하기
* 작은 num_leaves 사용하기
* min_data_in_leaf, min_sum_hessian_in_leaf 사용하기
* bagging_fraction, bagging_freq을 통해 bagging 사용하기
* feature_fraction을 통해서 feature을 sub-sampling하기
* 더 큰 훈련 데이터 사용하기
* lambda_l1, lambda_l2, min_gain_to_split을 사용하여 regularization 하기
* max_depth을 작게 설정하여 tree을 너무 deep하게 키우지 않기

이제 하나씩 살펴보도록 하자.



#### lambda_l1, lambda_l2

>- **reg_alpha** (*float**,* *optional* *(**default=0.**)*) – L1 regularization term on weights.
>- **reg_lambda** (*float**,* *optional* *(**default=0.**)*) – L2 regularization term on weights.

일종의 penalty을 조절하는 파라미터라고 보면 된다. 마치 Elasticnet에서 두 개의 penalty 파라미터가 존재하는 것과 유사하다. 과적합이 의심되면 튜닝하는 것을 추천한다.



#### num_leaves

> **num_leaves** (*int**,* *optional* *(**default=31**)*) – Maximum tree leaves for base learners.

모델의 복잡도를 조절하는 아주 중요한 파라미터이다. 크면 클수록 나무가 커져서 과적합의 위험이 있고 너무 작다면 underfitting의 위험이 있다. 공식 문서에 의하면, 간단하게는 **num_leaves = 2^(max_depth)** 을 추천하지만 max_depth와 함께 튜닝하는 것을 추천한다.



#### min_data_in_leaf

> **min_child_samples** (*int**,* *optional* *(**default=20**)*) – Minimum number of data needed in a child (leaf).

lgbm의 공식 문서인 [여기](https://lightgbm.readthedocs.io/en/latest/Parameters-Tuning.html#deal-with-over-fitting) 를 살펴보면, 과적합을 방지하기 위해 튜닝할 수 있는 파라미터로 소개되어 있다. 공식 문서에는 **매우** 중요한 파라미터라고 나와있다. num_leaves와 같이 조정하면 좋다. 값을 크게 두면 과적합을 방지할 수는 있지만 underfitting이 발생할 수 있다. 데이터 수가 많다면 수백, 수천으로 조정하면 좋다.



#### min_sum_hessian_in_leaf

> **min_child_weight** (*float**,* *optional* *(**default=1e-3**)*) – Minimum sum of instance weight (hessian) needed in a child (leaf).

얘도 과적합을 방지하기 위한 파라미터이다. xgboost에서는 min_child_weight와 동일한 파라미터이다. 이해하기가 조금 어려운데, [스택오버페이지](https://stats.stackexchange.com/questions/317073/explanation-of-min-child-weight-in-xgboost-algorithm) 에 설명이 잘 나와있다.



#### subsample

> **subsample** (*float**,* *optional* *(**default=1.**)*) – Subsample ratio of the training instance.

하나의 tree를 만들 때, 얼마만큼의 행을 사용할지에 대한 파라미터이다.

![image](https://user-images.githubusercontent.com/36855000/97137939-5a297180-179a-11eb-8038-b89f969ea52d.png)



#### feature_fraction

subsample 파라미터가 사용할 행 비율이었다면, feature_fraction은 사용할 열 비율이다. 이 파라미터를 잘 사용하면

* 훈련 시간을 줄일 수 있다.
* 과적합을 방지할 수 있다.

![image](https://user-images.githubusercontent.com/36855000/97138036-98bf2c00-179a-11eb-9203-a67f2482ccf9.png)



#### max_depth

> **max_depth** (*int**,* *optional* *(**default=-1**)*) – Maximum tree depth for base learners, <=0 means no limit.

tree을 얼마나 깊이 만들지에 대한 파라미터이다. 기본값이 -1인데, 이는 제한이 없다는 뜻으로 tree을 끝까지 키운다는 뜻일 것이다. 이는 과적합으로 이어질 가능성이 매우 높으므로 꼭 튜닝하는 것을 추천한다. 



#### max_bin

bin의 max 값에 대한 파라미터이다. lgbm의 논문을 보면, histogram binning을 통해서 optimal split을 찾는다. 즉, 연속형 변수를 histogram binning하여, search space을 훨씬 줄이는 원리인데, 여기서 얼마나 많은 수로 binning할지를 정하는 것이다.

<img src="https://user-images.githubusercontent.com/36855000/97139023-dfae2100-179c-11eb-8865-4a6ee4d8db44.png" alt="image" style="zoom:50%;" />



### Training parameters

모델 학습 시에 조정해야할 파라미터에 대해서 살펴본다.



#### num_iterations

> **n_estimators** (*int**,* *optional* *(**default=100**)*) – Number of boosted trees to fit.

얼마나 많은 수의 tree을 만들지에 대한 파라미터이다. 더 많은 tree을 만들 수록 학습이 잘 되겠지만 학습 시간이 많이 소요되고 과적합의 위험이 있다. 

우선은 작은 값으로 시작해서 튜닝을 하고 난 후에, 조금이라도 더 올리기 위해서 얘를 튜닝해보자.

또한 큰 값의 num_iterations을 사용한다면 작은 값의 learning_rate을 같이 사용하는 것이 좋으며 early_stoppig_rounds을 통해 의미 없는 이터레이션을 방지하자.



#### early_stoppig_rounds

> **early_stopping_rounds** (*int* *or* *None**,* *optional* *(**default=None**)*) – Activates early stopping. The model will train until the validation score stops improving.

만약 명시한 early_stopping_rounds 동안 validation score가 오르지 않으면, 훈련을 중단한다. 과적합을 방지하는데 쓰인다. 보통 num_iterations의 10%로 지정한다.



#### categorical_features

lgbm은 범주형 변수를 one-hot encoding 없이 다룰 수 있다. 범주형 변수의 범주가 매우 많다면, 이를 one-hot encoding 한다면 변수의 개수가 매우 많아질 뿐만 아니라 curse of dimension으로 인해 성능이 나빠질 수 있다는 것이 정설이다. 특히나, tree 계열 모델에서는 one-hot encoding을 통해서 만들어진 sparse matrix는 tree의 과적합을 가져올 수 있다. 따라서 범주형 변수를 one-hot encoding 없이 다룬다면 큰 장점이 될텐데, 부스팅 계열 모델에서는 lgbm, catboost가 이를 수행할 수 있고 xgboost에는 구현되어있지 않다. lgbm는 범주형 변수를 **fisher scoring** 을 통해서 encoding 한다고 한다. 이를 구현하는 방법은 크게 두 가지가 있다.

* 범주형 변수의 칼럼 인덱스를 지정한다.

  ```
  cat_col = dataset_name.select_dtypes(‘object’).columns.tolist()
  ```

* 범주형 변수의 type을 **category** 로 바꾼다.

  ```
  dataset_name = dataset_name[str_cols].astype('category')
  ```

  위와 같이 type을 category로 바꿔주면, lgbm.train() 에서 categorical_features을 지정해줄 필요가 없다. (지정한다면 에러가 뜬다.)



#### is_unbalance vs scale_pos_weight

unbalance 분류 문제에서 사용되는 파라미터이다. is_unbalance는 Boolean으로 지정하는데, True라면 자동으로 optimal weight을 찾아준다. scale_pos_weight는 optimal weight을 수동으로 직접 입력하는 식이다.



여태까지는 분류, 회귀 문제 구별 없이 모두 사용되는 파라미터이다. 아래는 이 두 문제에 대해서 구분을 해야하는 파라미터들을 정리하였다.

| parameter        | Classification            | Regression       |
| ---------------- | ------------------------- | ---------------- |
| objective        | binary/multiclass         | regression       |
| metric           | AUC, logloss, etc.        | RMSE, MAPE, etc. |
| is_unbalance     | Boolean                   |                  |
| scale_pos_weight | N / P                     |                  |
| num_class        | multi-classification only |                  |
| reg_sqrt         |                           | fitting sqt(y)   |

특히 목표에 맞는 metric을 잘 설정해야함에 유의하자.



### lgbm 파라미터 튜닝 순서 정리

여태까지 아주 자세하게 파라미터의 의미를 살펴보았다. 그러면 도대체 어떻게 튜닝을 해야할까?

1. num_iterations, early_stoppig_rounds을 우선 작게 설정한다.
2. max_depth, num_leaves, min_data_in_leaf을 반드시 포함하여 튜닝한다.
3. 과적합이 의심된다면 max_bin, min_sum_hessian_in_leaf, bagging 관련 파라미터, lambda_l1을 시도해본다.
4. 마지막으로 num_iterations, early_stopping_rounds, learning_rate을 조정하여 최종 성능을 달성한다.



### Examples with hyperopt

베이지안 최적화를 이용하여 주요 파라미터에 대해서 튜닝을 해보았다. 데이터는 [캐글](https://www.kaggle.com/c/santander-customer-transaction-prediction/data) 에서 가져왔다.

```python
import pandas as pd
import numpy as np
import lightgbm as lgb
from hyperopt import fmin, tpe, STATUS_OK, STATUS_FAIL, Trials, hp
from sklearn.metrics import auc

from sklearn.model_selection import train_test_split

data = pd.read_csv('/Users/shinbo/ML/data/santander-customer-transaction-prediction/train.csv')
X = data.drop(columns=['ID_code','target'])
y = data['target']

SEARCH_PARAMS = {'learning_rate': 0.1,
                 'max_depth': -1,
                 'boosting': 'gbdt'}

FIXED_PARAMS={'objective': 'binary',
              'metric': 'auc',
              'is_unbalance': True,
              'num_boost_round':300,
              'early_stopping_rounds':30}

X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.2, random_state=1234)
train_data = lgb.Dataset(X_train, label=y_train)
valid_data = lgb.Dataset(X_valid, label=y_valid, reference=train_data)


def objective(SEARCH_PARAMS):
    params = {'metric':FIXED_PARAMS['metric'],
         'objective':FIXED_PARAMS['objective'],
         'is_unbalance':FIXED_PARAMS['is_unbalance'],
         'num_boost_round':FIXED_PARAMS['num_boost_round'],
          'early_stopping_rounds':FIXED_PARAMS['early_stopping_rounds'],
         **SEARCH_PARAMS}

    model = lgb.train(params, train_data,                     
                     valid_sets=[valid_data],
                     num_boost_round=FIXED_PARAMS['num_boost_round'],
                     early_stopping_rounds=FIXED_PARAMS['early_stopping_rounds'],
                     valid_names=['valid'])

    score = model.best_score['valid']['auc']
    
    return -1.0 * score

def objective_final_tuning(SEARCH_PARAMS):
    params = {'metric':FIXED_PARAMS['metric'],
             'objective':FIXED_PARAMS['objective'],
             'is_unbalance':FIXED_PARAMS['is_unbalance'],
              'early_stopping_rounds': round(SEARCH_PARAMS['num_boost_round']/10),
             **TUNED_PARAMS,
             **SEARCH_PARAMS}
    
    model = lgb.train(params, train_data,                     
                     valid_sets=[valid_data],
                     valid_names=['valid'])

    score = model.best_score['valid']['auc']
    
    return -1.0 * score

# lgbm parameters
lgbm_space = {
        "max_depth": hp.choice("max_depth", range(1,20)),
        "num_leaves": hp.choice('num_leaves', range(10, 200)),
        "feature_fraction": hp.quniform("feature_fraction", 0.5, 1.0, 0.1),
        "bagging_fraction": hp.quniform("bagging_fraction", 0.5, 1.0, 0.1),
        "bagging_freq": hp.choice("bagging_freq", np.linspace(0, 50, 10, dtype=int)),
        "reg_alpha": hp.uniform("reg_alpha", 0, 1),
        "reg_lambda": hp.uniform("reg_lambda", 0, 1),
        "min_child_weight": hp.uniform('min_child_weight', 0.5, 10)
    }

final_lgbm_space = {
        "learning_rate": hp.loguniform("learning_rate", np.log(0.01), np.log(0.5)),
        "num_boost_round": hp.choice('num_boost_round', range(100, 3001))
    }
```

튜닝을 하지 않고 default 값으로 적합한 모델과 hyperopt을 이용해 파라미터를 튜닝한 모델을 auc 기준으로 비교해보았다.

```python
# baseline model
basemodel = lgb.train(FIXED_PARAMS,
                     train_data,                     
                     valid_sets=[valid_data],
                     valid_names=['valid']
                     )

# parameter tuning with fixed other parameters
TUNED_PARAMS = fmin(objective,lgbm_space,
                        algo=tpe.suggest,max_evals=50)

final_model = fmin(objective_final_tuning,final_lgbm_space,
                        algo=tpe.suggest,max_evals=50)
```



#### 실혐 결과

|      | 튜닝 전 | 튜닝 후 |
| ---- | ------- | ------- |
| AUC  | 0.89    | 0.898   |



### Reading Materials

* https://statweb.stanford.edu/~jhf/ftp/trebst.pdf : gradient boosting decision trees paper
* https://arxiv.org/pdf/1505.01866.pdf : dart paper
* https://papers.nips.cc/paper/6907-lightgbm-a-highly-efficient-gradient-boosting-decision-tree.pdf : lgbm paper